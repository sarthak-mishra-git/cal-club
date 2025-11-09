import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/onboarding_repository.dart';
import '../../network/token_storage.dart';
import '../../models/onboarding/onboarding_answer_model.dart';
import '../../models/onboarding/plan_data_model.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository repository;

  OnboardingBloc({required this.repository}) : super(OnboardingInitial()) {
    on<FetchQuestions>(_onFetchQuestions);
    on<LoadExistingAnswers>(_onLoadExistingAnswers);
    on<NavigateToQuestion>(_onNavigateToQuestion);
    on<UpdateAnswer>(_onUpdateAnswer);
    on<SubmitAnswers>(_onSubmitAnswers);
    on<CalculateGoals>(_onCalculateGoals);
    on<UpdateProfileGoals>(_onUpdateProfileGoals);
    on<ResetOnboarding>(_onResetOnboarding);
  }

  Future<void> _onFetchQuestions(
    FetchQuestions event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      final response = await repository.fetchQuestions();
      if (response.success) {
        emit(OnboardingLoaded(
          questions: response.questions,
          currentIndex: 0,
          answers: {},
        ));
        
        // Automatically load existing answers after questions are fetched
        add(LoadExistingAnswers());
      } else {
        emit(OnboardingError(message: 'Failed to fetch questions'));
      }
    } catch (e) {
      emit(OnboardingError(message: 'Error fetching questions: $e'));
    }
  }

  Future<void> _onLoadExistingAnswers(
    LoadExistingAnswers event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is! OnboardingLoaded) return;
    
    final currentState = state as OnboardingLoaded;
    emit(currentState.copyWith(isLoading: true));
    
    try {
      final existingAnswers = await repository.getExistingAnswers();
      final answersMap = <String, List<String>>{};
      String? userName;
      double? height;
      double? weight;
      int? age;
      String? gender;
      String? goalType;
      double? paceKgPerWeek;
      double? desiredWeightKg;
      String? activityLevel;
      int? workoutsPerWeek;
      
      for (final answer in existingAnswers) {
        // Skip answers with empty questionId or empty values
        if (answer.questionId.isEmpty || 
            answer.values.isEmpty || 
            !answer.values.any((v) => v.trim().isNotEmpty)) {
          continue;
        }
        answersMap[answer.questionId] = answer.values;
        
        final question = currentState.questions.firstWhere(
          (q) => q.id == answer.questionId,
          orElse: () => currentState.questions.first,
        );
        
        // Extract userName from NAME_INPUT question
        if (question.type == 'NAME_INPUT' && answer.values.isNotEmpty) {
          userName = answer.values.first;
        }
        // Extract height and weight from PICKER question with "height and weight"
        else if (question.type == 'PICKER' && 
                 question.text.toLowerCase().contains('height and weight') &&
                 answer.values.isNotEmpty) {
          try {
            final answerStr = answer.values.first;
            // Parse format: "height_170.0&weight_70.0"
            final heightMatch = RegExp(r'height_([\d.]+)').firstMatch(answerStr);
            final weightMatch = RegExp(r'weight_([\d.]+)').firstMatch(answerStr);
            if (heightMatch != null && weightMatch != null) {
              height = double.parse(heightMatch.group(1)!);
              weight = double.parse(weightMatch.group(1)!);
            } else {
              // Fallback to old format for backward compatibility
              final parts = answerStr.split(',');
              if (parts.length >= 2) {
                height = double.parse(parts[0]);
                weight = double.parse(parts[1]);
              }
            }
          } catch (e) {
            // Ignore parsing errors
          }
        }
        // Extract age from DATE question
        else if (question.type == 'DATE' && answer.values.isNotEmpty) {
          try {
            final dob = DateTime.parse(answer.values.first);
            final today = DateTime.now();
            int calculatedAge = today.year - dob.year;
            if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
              calculatedAge--;
            }
            age = calculatedAge;
          } catch (e) {
            // Ignore parsing errors
          }
        }
        // Extract gender from SELECT question with "gender"
        else if (question.type == 'SELECT' && 
                 question.text.toLowerCase().contains('gender') &&
                 answer.values.isNotEmpty) {
          // Find the selected option text
          final selectedValue = answer.values.first;
          final selectedOption = question.options.firstWhere(
            (opt) => opt.text.toLowerCase() == selectedValue.toLowerCase(),
            orElse: () => question.options.first,
          );
          gender = selectedOption.text;
        }
        // Extract goal type from SELECT question with "goal"
        else if (question.type == 'SELECT' && 
                 question.text.toLowerCase().contains('goal') &&
                 answer.values.isNotEmpty) {
          final answerText = answer.values.first;
          goalType = _mapGoalTextToGoalType(answerText);
          print('LoadExistingAnswers: goal question answerText="$answerText", mappedGoalType="$goalType"');
        }
        // Extract target weight from PICKER question with "target weight"
        else if (question.type == 'PICKER' && 
                 question.text.toLowerCase().contains('target weight') &&
                 answer.values.isNotEmpty) {
          try {
            final answerStr = answer.values.first;
            // Parse format: "weight_70.0"
            final weightMatch = RegExp(r'weight_([\d.]+)').firstMatch(answerStr);
            if (weightMatch != null) {
              desiredWeightKg = double.parse(weightMatch.group(1)!);
            } else {
              // Fallback to old format for backward compatibility
              desiredWeightKg = double.parse(answerStr);
            }
          } catch (e) {
            // Ignore parsing errors
          }
        }
        // Extract activity level from SELECT question with "typical day"
        else if (question.type == 'SELECT' && 
                 question.text.toLowerCase().contains('typical day') &&
                 answer.values.isNotEmpty) {
          activityLevel = _mapActivityTextToActivityLevel(answer.values.first);
        }
        // Extract workouts per week from SELECT question with "workout"
        else if (question.type == 'SELECT' && 
                 question.text.toLowerCase().contains('workout') &&
                 answer.values.isNotEmpty) {
          workoutsPerWeek = _mapWorkoutTextToWorkoutsPerWeek(answer.values.first);
        }
      }
      
      // Second pass: Extract pace (needs goalType to be set from first pass)
      for (final answer in existingAnswers) {
        final question = currentState.questions.firstWhere(
          (q) => q.id == answer.questionId,
          orElse: () => currentState.questions.first,
        );
        
        // Extract pace from SLIDER question (needs goalType from first pass)
        if (question.type == 'SLIDER' && answer.values.isNotEmpty) {
          try {
            final paceValue = double.parse(answer.values.first);
            // Set pace based on goal type:
            // - lose: negative (e.g., -0.4)
            // - gain: positive (e.g., 0.4)
            // - maintain: positive (e.g., 0.4) - keep as-is
            if (goalType == 'lose') {
              paceKgPerWeek = -paceValue;
            } else {
              // gain or maintain: keep positive
              paceKgPerWeek = paceValue;
            }
          } catch (e) {
            // Ignore parsing errors
          }
        }
      }
      
      emit(currentState.copyWith(
        answers: answersMap,
        isLoading: false,
        userName: userName,
        height: height,
        weight: weight,
        age: age,
        gender: gender,
        goalType: goalType,
        paceKgPerWeek: paceKgPerWeek,
        desiredWeightKg: desiredWeightKg,
        activityLevel: activityLevel,
        workoutsPerWeek: workoutsPerWeek,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoading: false));
      // Don't emit error for existing answers, just continue
    }
  }

  void _onNavigateToQuestion(
    NavigateToQuestion event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is! OnboardingLoaded) return;
    
    final currentState = state as OnboardingLoaded;
    if (event.index >= 0 && event.index < currentState.questions.length) {
      emit(currentState.copyWith(currentIndex: event.index));
    }
  }

  void _onUpdateAnswer(
    UpdateAnswer event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is! OnboardingLoaded) return;
    
    final currentState = state as OnboardingLoaded;
    
    // Skip if questionId is empty or if all values are empty
    if (event.questionId.isEmpty || 
        event.values.isEmpty || 
        !event.values.any((v) => v.trim().isNotEmpty)) {
      return;
    }
    
    final updatedAnswers = Map<String, List<String>>.from(currentState.answers);
    updatedAnswers[event.questionId] = event.values;
    
    final question = currentState.questions.firstWhere(
      (q) => q.id == event.questionId,
      orElse: () => currentState.questions.first,
    );
    
    print('DEBUG: _onUpdateAnswer - questionId="${event.questionId}", question.text="${question.text}", question.type="${question.type}", values="${event.values}"');
    
    // Extract data based on question type and store in state
    String? userName = currentState.userName;
    double? height = currentState.height;
    double? weight = currentState.weight;
    int? age = currentState.age;
    String? gender = currentState.gender;
    String? goalType = currentState.goalType;
    double? paceKgPerWeek = currentState.paceKgPerWeek;
    double? desiredWeightKg = currentState.desiredWeightKg;
    String? activityLevel = currentState.activityLevel;
    int? workoutsPerWeek = currentState.workoutsPerWeek;
    
    if (question.type == 'NAME_INPUT' && event.values.isNotEmpty) {
      userName = event.values.first;
    }
    // Extract height and weight from PICKER question with "height and weight"
    else if (question.type == 'PICKER' && 
             question.text.toLowerCase().contains('height and weight') &&
             event.values.isNotEmpty) {
      try {
        final answerStr = event.values.first;
        // Parse format: "height_170.0&weight_70.0"
        final heightMatch = RegExp(r'height_([\d.]+)').firstMatch(answerStr);
        final weightMatch = RegExp(r'weight_([\d.]+)').firstMatch(answerStr);
        if (heightMatch != null && weightMatch != null) {
          height = double.parse(heightMatch.group(1)!);
          weight = double.parse(weightMatch.group(1)!);
        } else {
          // Fallback to old format for backward compatibility
          final parts = answerStr.split(',');
          if (parts.length >= 2) {
            height = double.parse(parts[0]);
            weight = double.parse(parts[1]);
          }
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    // Extract age from DATE question
    else if (question.type == 'DATE' && event.values.isNotEmpty) {
      try {
        final dob = DateTime.parse(event.values.first);
        final today = DateTime.now();
        int calculatedAge = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
          calculatedAge--;
        }
        age = calculatedAge;
      } catch (e) {
        // Ignore parsing errors
      }
    }
    // Extract gender from SELECT question with "gender"
    else if (question.type == 'SELECT' && 
             question.text.toLowerCase().contains('gender') &&
             event.values.isNotEmpty) {
      // Find the selected option text
      final selectedValue = event.values.first;
      final selectedOption = question.options.firstWhere(
        (opt) => opt.text.toLowerCase() == selectedValue.toLowerCase(),
        orElse: () => question.options.first,
      );
      gender = selectedOption.text;
    }
    // Extract goal type from SELECT question with "goal"
    else if (question.type == 'SELECT' && 
             question.text.toLowerCase().contains('goal') &&
             event.values.isNotEmpty) {
      print('DEBUG: Matched goal question condition!');
      final answerText = event.values.first;
      print('DEBUG: Goal question detected! question.text="${question.text}", answerText="$answerText"');
      final newGoalType = _mapGoalTextToGoalType(answerText);
      print('Goal selection: answerText="$answerText", mappedGoalType="$newGoalType"');
      goalType = newGoalType;
      print('DEBUG: Setting goalType to "$goalType"');
      
      // If goal type changes to "lose" and pace is positive, negate it
      if (newGoalType == 'lose' && paceKgPerWeek != null && paceKgPerWeek! > 0) {
        paceKgPerWeek = -paceKgPerWeek!;
      }
      // If goal type changes to "gain" or "maintain" and pace is negative, make it positive
      else if ((newGoalType == 'gain' || newGoalType == 'maintain') && paceKgPerWeek != null && paceKgPerWeek! < 0) {
        paceKgPerWeek = -paceKgPerWeek!;
      }
    }
    // Extract pace from SLIDER question
    else if (question.type == 'SLIDER' && event.values.isNotEmpty) {
      try {
        final paceValue = double.parse(event.values.first);
        // Set pace based on goal type:
        // - lose: negative (e.g., -0.4)
        // - gain: positive (e.g., 0.4)
        // - maintain: positive (e.g., 0.4) - keep as-is
        if (goalType == 'lose') {
          paceKgPerWeek = -paceValue;
        } else {
          // gain or maintain: keep positive
          paceKgPerWeek = paceValue;
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    // Extract target weight from PICKER question with "target weight"
    else if (question.type == 'PICKER' && 
             question.text.toLowerCase().contains('target weight') &&
             event.values.isNotEmpty) {
      try {
        final answerStr = event.values.first;
        // Parse format: "weight_70.0"
        final weightMatch = RegExp(r'weight_([\d.]+)').firstMatch(answerStr);
        if (weightMatch != null) {
          desiredWeightKg = double.parse(weightMatch.group(1)!);
        } else {
          // Fallback to old format for backward compatibility
          desiredWeightKg = double.parse(answerStr);
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    // Extract activity level from SELECT question with "typical day"
    else if (question.type == 'SELECT' && 
             question.text.toLowerCase().contains('typical day') &&
             event.values.isNotEmpty) {
      activityLevel = _mapActivityTextToActivityLevel(event.values.first);
    }
    // Extract workouts per week from SELECT question with "workout"
    else if (question.type == 'SELECT' && 
             question.text.toLowerCase().contains('workout') &&
             event.values.isNotEmpty) {
      workoutsPerWeek = _mapWorkoutTextToWorkoutsPerWeek(event.values.first);
    }
    
    print('DEBUG: _onUpdateAnswer - final goalType before emit: "$goalType"');
    emit(currentState.copyWith(
      answers: updatedAnswers,
      userName: userName,
      height: height,
      weight: weight,
      age: age,
      gender: gender,
      goalType: goalType,
      paceKgPerWeek: paceKgPerWeek,
      desiredWeightKg: desiredWeightKg,
      activityLevel: activityLevel,
      workoutsPerWeek: workoutsPerWeek,
    ));
    print('DEBUG: _onUpdateAnswer - emitted state with goalType: "$goalType"');
  }

  Future<void> _onSubmitAnswers(
    SubmitAnswers event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is! OnboardingLoaded) return;
    
    final currentState = state as OnboardingLoaded;
    emit(currentState.copyWith(isSubmitting: true));
    
    try {
      // Get userId from storage
      final user = await TokenStorage.getUser();
      if (user == null) {
        emit(OnboardingError(message: 'User not authenticated'));
        return;
      }
      
      final userId = user.id;
      final answers = currentState.answers.entries
          .where((entry) => 
              entry.key.isNotEmpty && 
              entry.value.isNotEmpty &&
              entry.value.any((v) => v.trim().isNotEmpty))
          .map((entry) => OnboardingAnswer(
                id: '',
                userId: userId,
                questionId: entry.key,
                values: entry.value,
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              ))
          .toList();
      
      final response = await repository.submitAnswers(answers);
      if (response.success) {
        emit(OnboardingCompleted());
      } else {
        emit(OnboardingError(message: response.message));
      }
    } catch (e) {
      emit(OnboardingError(message: 'Error submitting answers: $e'));
    }
  }

  Future<void> _onCalculateGoals(
    CalculateGoals event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is! OnboardingLoaded) return;
    
    final currentState = state as OnboardingLoaded;
    emit(currentState.copyWith(isLoading: true));
    
    try {
      // All values are already stored in state - just extract them
      final sexAtBirth = _mapGenderToSexAtBirth(currentState.gender);
      final ageYears = currentState.age;
      final heightCm = currentState.height;
      final weightKg = currentState.weight;
      final goalType = currentState.goalType ?? 'maintain';
      print('CalculateGoals: goalType from state="${currentState.goalType}", using="$goalType"');
      // Default pace based on goal type:
      // - lose: -0.5 kg/week
      // - gain: 0.5 kg/week
      // - maintain: 0.5 kg/week (keep positive)
      final paceKgPerWeek = currentState.paceKgPerWeek ?? 
        (goalType == 'lose' ? -0.5 : 0.5);
      print('CalculateGoals: paceKgPerWeek from state="${currentState.paceKgPerWeek}", using="$paceKgPerWeek"');
      final desiredWeightKg = currentState.desiredWeightKg;
      final activityLevel = currentState.activityLevel ?? 'active';
      final workoutsPerWeek = currentState.workoutsPerWeek ?? 3;
      
      // Validate required fields
      if (sexAtBirth == null || ageYears == null || heightCm == null || weightKg == null) {
        emit(OnboardingError(message: 'Missing required information for goal calculation'));
        return;
      }
      
      // Build request payload
      final goalData = <String, dynamic>{
        'sex_at_birth': sexAtBirth,
        'age_years': ageYears,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'goal_type': goalType,
        'pace_kg_per_week': paceKgPerWeek,
        'activity_level': activityLevel,
        'workouts_per_week': workoutsPerWeek,
        'avg_workout_duration_min': 45,
        'avg_workout_intensity': 'moderate',
      };
      
      if (desiredWeightKg != null) {
        goalData['desired_weight_kg'] = desiredWeightKg;
      }
      
      // Call API
      final response = await repository.calculateAndSaveGoals(goalData);
      
      // Extract planData from response
      PlanData? planData;
      if (response['planData'] != null) {
        planData = PlanData.fromJson(response['planData'] as Map<String, dynamic>);
      }
      
      emit(currentState.copyWith(
        isLoading: false,
        calculatedPlanData: planData,
      ));
    } catch (e) {
      emit(OnboardingError(message: 'Error calculating goals: $e'));
    }
  }

  Future<void> _onUpdateProfileGoals(
    UpdateProfileGoals event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is! OnboardingLoaded) return;
    
    final currentState = state as OnboardingLoaded;
    emit(currentState.copyWith(isLoading: true));
    
    try {
      await repository.updateProfileGoals(
        dailyCalories: event.dailyCalories,
        dailyProtein: event.dailyProtein,
        dailyCarbs: event.dailyCarbs,
        dailyFats: event.dailyFats,
      );
      
      emit(currentState.copyWith(isLoading: false));
    } catch (e) {
      emit(OnboardingError(message: 'Error updating profile goals: $e'));
    }
  }

  String? _mapGenderToSexAtBirth(String? gender) {
    if (gender == null) return null;
    final lowerGender = gender.toLowerCase();
    if (lowerGender.contains('male') && !lowerGender.contains('fe')) {
      return 'male';
    } else if (lowerGender.contains('female')) {
      return 'female';
    }
    return 'male'; // Default
  }

  String _mapGoalTextToGoalType(String goalText) {
    final lowerText = goalText.toLowerCase().trim();
    
    // Explicit matching for known options
    if (lowerText == 'lose fat and gain muscle' || lowerText == 'lose fat') {
      return 'lose';
    } else if (lowerText == 'gain muscle') {
      return 'gain';
    } else if (lowerText == 'improve lifestyle') {
      return 'maintain';
    }
    
    // Fallback to pattern matching
    if (lowerText.contains('lose') && lowerText.contains('fat')) {
      return 'lose';
    } else if (lowerText.contains('gain') && lowerText.contains('muscle')) {
      return 'gain';
    } else if (lowerText.contains('lose')) {
      return 'lose';
    } else if (lowerText.contains('gain')) {
      return 'gain';
    }
    return 'maintain';
  }

  String _mapActivityTextToActivityLevel(String activityText) {
    final lowerText = activityText.toLowerCase();
    if (lowerText.contains('sedentary') || lowerText.contains('desk')) {
      return 'sedentary';
    } else if (lowerText.contains('light') || lowerText.contains('occasional')) {
      return 'light';
    } else if (lowerText.contains('very active') || lowerText.contains('intense')) {
      return 'very_active';
    } else if (lowerText.contains('dynamic') || lowerText.contains('varied')) {
      return 'dynamic';
    }
    return 'active'; // Default
  }

  int _mapWorkoutTextToWorkoutsPerWeek(String workoutText) {
    final lowerText = workoutText.toLowerCase();
    if (lowerText.contains('0-2')) {
      return 1;
    } else if (lowerText.contains('3-5')) {
      return 4;
    } else if (lowerText.contains('6+')) {
      return 7;
    }
    return 3; // Default
  }


  void _onResetOnboarding(
    ResetOnboarding event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingInitial());
  }
}
