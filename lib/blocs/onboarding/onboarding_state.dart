import 'package:equatable/equatable.dart';
import '../../models/onboarding/onboarding_question_model.dart';
import '../../models/onboarding/onboarding_answer_model.dart';
import '../../models/onboarding/plan_data_model.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingQuestion> questions;
  final int currentIndex;
  final Map<String, List<String>> answers;
  final bool isLoading;
  final bool isSubmitting;
  final String? userName;
  final double? height;
  final double? weight;
  final int? age;
  final String? gender;
  final String? goalType;
  final double? paceKgPerWeek;
  final double? desiredWeightKg;
  final String? activityLevel;
  final int? workoutsPerWeek;
  final PlanData? calculatedPlanData;

  const OnboardingLoaded({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    this.isLoading = false,
    this.isSubmitting = false,
    this.userName,
    this.height,
    this.weight,
    this.age,
    this.gender,
    this.goalType,
    this.paceKgPerWeek,
    this.desiredWeightKg,
    this.activityLevel,
    this.workoutsPerWeek,
    this.calculatedPlanData,
  });

  OnboardingLoaded copyWith({
    List<OnboardingQuestion>? questions,
    int? currentIndex,
    Map<String, List<String>>? answers,
    bool? isLoading,
    bool? isSubmitting,
    String? userName,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? goalType,
    double? paceKgPerWeek,
    double? desiredWeightKg,
    String? activityLevel,
    int? workoutsPerWeek,
    PlanData? calculatedPlanData,
  }) {
    return OnboardingLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      userName: userName ?? this.userName,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goalType: goalType ?? this.goalType,
      paceKgPerWeek: paceKgPerWeek ?? this.paceKgPerWeek,
      desiredWeightKg: desiredWeightKg ?? this.desiredWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      calculatedPlanData: calculatedPlanData ?? this.calculatedPlanData,
    );
  }

  bool get hasAnswer {
    if (currentIndex >= questions.length) return false;
    final question = questions[currentIndex];
    final answer = answers[question.id];
    return answer != null && answer.isNotEmpty;
  }

  bool get isFirstQuestion => currentIndex == 0;
  bool get isLastQuestion => currentIndex == questions.length - 1;
  double get progress => questions.isEmpty ? 0.0 : (currentIndex + 1) / questions.length;

  @override
  List<Object?> get props => [questions, currentIndex, answers, isLoading, isSubmitting, userName, height, weight, age, gender, goalType, paceKgPerWeek, desiredWeightKg, activityLevel, workoutsPerWeek, calculatedPlanData];
}

class OnboardingSubmitting extends OnboardingState {
  final List<OnboardingQuestion> questions;
  final Map<String, List<String>> answers;

  const OnboardingSubmitting({
    required this.questions,
    required this.answers,
  });

  @override
  List<Object?> get props => [questions, answers];
}

class OnboardingCompleted extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object?> get props => [message];
}
