import 'package:equatable/equatable.dart';
import '../../models/onboarding/onboarding_answer_model.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class FetchQuestions extends OnboardingEvent {}

class LoadExistingAnswers extends OnboardingEvent {}

class NavigateToQuestion extends OnboardingEvent {
  final int index;

  const NavigateToQuestion(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateAnswer extends OnboardingEvent {
  final String questionId;
  final List<String> values;

  const UpdateAnswer({
    required this.questionId,
    required this.values,
  });

  @override
  List<Object?> get props => [questionId, values];
}

class SubmitAnswers extends OnboardingEvent {}

class CalculateGoals extends OnboardingEvent {}

class UpdateProfileGoals extends OnboardingEvent {
  final double dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFats;

  const UpdateProfileGoals({
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFats,
  });

  @override
  List<Object?> get props => [dailyCalories, dailyProtein, dailyCarbs, dailyFats];
}

class ResetOnboarding extends OnboardingEvent {}
