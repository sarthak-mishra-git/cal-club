import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/onboarding/onboarding_bloc.dart';
import '../../blocs/onboarding/onboarding_event.dart';
import '../../blocs/onboarding/onboarding_state.dart';
import '../../models/onboarding/onboarding_question_model.dart';
import '../../network/token_storage.dart';
import 'widgets/no_input_widget.dart';
import 'widgets/name_input_widget.dart';
import 'widgets/select_widget.dart';
import 'widgets/multiselect_widget.dart';
import 'widgets/number_widget.dart';
import 'widgets/date_widget.dart';
import 'widgets/text_widget.dart';
import 'widgets/textarea_widget.dart';
import 'widgets/rating_widget.dart';
import 'widgets/slider_widget.dart';
import 'widgets/picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'widgets/referral_input_widget.dart';
import 'widgets/summary_widget.dart';
import 'widgets/plan_summary_widget.dart';
import 'widgets/meal_timing_widget.dart';
import 'widgets/notification_permission_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch questions first, then load existing answers
    context.read<OnboardingBloc>().add(FetchQuestions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            // Mark onboarding as completed
            TokenStorage.setOnboardingCompleted();
            // Navigate to dashboard after onboarding completion
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/dashboard',
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Onboarding completed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is OnboardingLoaded && !state.isLoading) {
            // Check if we just completed goal calculation and should navigate
            final currentQuestion = state.questions[state.currentIndex];
            if (currentQuestion.type == 'GOAL_CALCULATION' && state.calculatedPlanData != null) {
              // Navigate to next question after successful calculation
              // Use a small delay to ensure state is updated
              Future.delayed(const Duration(milliseconds: 100), () {
                if (context.mounted && !state.isLastQuestion) {
                  context.read<OnboardingBloc>().add(
                    NavigateToQuestion(state.currentIndex + 1)
                  );
                }
              });
            }
          }
        },
        builder: (context, state) {
          if (state is OnboardingLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is OnboardingLoaded) {
            return _buildOnboardingContent(state);
          }

          if (state is OnboardingSubmitting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Submitting your answers...'),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingContent(OnboardingLoaded state) {
    final question = state.questions[state.currentIndex];
    final currentAnswer = state.answers[question.id];

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                _buildQuestionWidget(question, currentAnswer, state),
                _buildHeader(state),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(state),
        ],
      ),
    );
  }

  Widget _buildHeader(OnboardingLoaded state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          // Back/Exit arrow
          Container(
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6F7F9),
            ),
            child: IconButton(
              iconSize: 15,
              onPressed: state.isFirstQuestion
                  ? () => _showExitConfirmation()
                  : () => context.read<OnboardingBloc>().add(
                      NavigateToQuestion(state.currentIndex - 1)
                    ),
              icon: Icon(
                CupertinoIcons.back,
                size: 20,
                color: state.isFirstQuestion ? Colors.grey[400] : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Progress bar
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: state.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(
    OnboardingQuestion question,
    List<String>? currentAnswer,
    OnboardingLoaded state,
  ) {
    // Replace {name} placeholder with actual userName
    final processedQuestion = _replaceNamePlaceholder(question, state.userName);
    
    return SingleChildScrollView(
      child: _getQuestionWidget(processedQuestion, currentAnswer, state),
    );
  }
  
  OnboardingQuestion _replaceNamePlaceholder(OnboardingQuestion question, String? userName) {
    if (userName == null || userName.isEmpty) {
      return question;
    }
    
    final text = question.text.replaceAll('{name}', userName);
    final subtext = question.subtext?.replaceAll('{name}', userName);
    
    return OnboardingQuestion(
      id: question.id,
      text: text,
      subtext: subtext,
      type: question.type,
      options: question.options,
      sequence: question.sequence,
      image: question.image,
      planData: question.planData,
    );
  }

  Widget _getQuestionWidget(
    OnboardingQuestion question,
    List<String>? currentAnswer,
    OnboardingLoaded state,
  ) {
    switch (question.type) {
      case 'NO_INPUT':
      case 'GOAL_CALCULATION':
        return NoInputWidget(
          question: question,
          currentAnswer: currentAnswer,
        );
      case 'NAME_INPUT':
        return NameInputWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'SELECT':
        return SelectWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'MULTISELECT':
        return MultiSelectWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'NUMBER':
        return NumberWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'DATE':
        return DateWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'TEXT':
        return TextWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'TEXTAREA':
        return TextAreaWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'RATING':
        return RatingWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'SLIDER':
        return SliderWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'PICKER':
        return PickerWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'APPLE_HEALTH':
        return _buildAppleHealthPlaceholder(question);
      case 'REFERRAL_INPUT':
        return ReferralInputWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'SUMMARY':
        return SummaryWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
          state: state,
        );
      case 'PLAN_SUMMARY':
        return PlanSummaryWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
          state: state,
        );
      case 'MEAL_TIMING':
        return MealTimingWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      case 'NOTIFICATION_PERMISSION':
        return NotificationPermissionWidget(
          question: question,
          currentAnswer: currentAnswer,
          onAnswerChanged: (values) => _updateAnswer(question.id, values),
        );
      default:
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
          child: Text(
            'Unsupported question type: ${question.type}',
            style: const TextStyle(fontSize: 16),
          ),
        );
    }
  }

  Widget _buildAppleHealthPlaceholder(OnboardingQuestion question) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6F7F9),
            ),
            child: Icon(
              Icons.health_and_safety,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (question.subtext != null && question.subtext!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              question.subtext!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              'Apple Health integration coming soon',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(OnboardingLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (state.hasAnswer || 
                     state.questions[state.currentIndex].type == 'NO_INPUT' ||
                     state.questions[state.currentIndex].type == 'GOAL_CALCULATION' ||
                     state.questions[state.currentIndex].type == 'APPLE_HEALTH' ||
                      state.questions[state.currentIndex].type == 'SLIDER' ||
                      state.questions[state.currentIndex].type == 'PICKER' ||
                      state.questions[state.currentIndex].type == 'DATE' ||
                      state.questions[state.currentIndex].type == 'SUMMARY' ||
                      state.questions[state.currentIndex].type == 'REFERRAL_INPUT' ||
                      state.questions[state.currentIndex].type == 'PLAN_SUMMARY' ||
                      state.questions[state.currentIndex].type == 'MEAL_TIMING' ||
                      state.questions[state.currentIndex].type == 'NOTIFICATION_PERMISSION')
                     && !state.isLoading
              ? () {
                  if (state.questions[state.currentIndex].type == 'GOAL_CALCULATION') {
                    // Call API first, then navigate on success
                    context.read<OnboardingBloc>().add(CalculateGoals());
                    // Navigation will happen in BlocListener after successful calculation
                    return;
                  }
                  if (state.isLastQuestion) {
                    context.read<OnboardingBloc>().add(SubmitAnswers());
                  } else {
                    context.read<OnboardingBloc>().add(
                      NavigateToQuestion(state.currentIndex + 1)
                    );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: state.isLoading && state.questions[state.currentIndex].type == 'GOAL_CALCULATION'
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  state.isLastQuestion ? 'Submit' : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  void _updateAnswer(String questionId, List<String> values) {
    context.read<OnboardingBloc>().add(
      UpdateAnswer(questionId: questionId, values: values),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Onboarding'),
        content: const Text('Are you sure you want to exit? Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
