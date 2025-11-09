import 'package:equatable/equatable.dart';
import 'onboarding_question_model.dart';
import 'onboarding_answer_model.dart';

class OnboardingGetAnswersResponse extends Equatable {
  final bool success;
  final List<OnboardingAnswer> data;
  final int count;

  const OnboardingGetAnswersResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  factory OnboardingGetAnswersResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingGetAnswersResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((d) => OnboardingAnswer.fromJson(d))
          .toList() ?? [],
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [success, data, count];
}

class OnboardingQuestionsResponse extends Equatable {
  final bool success;
  final List<OnboardingQuestion> questions;
  final int count;

  const OnboardingQuestionsResponse({
    required this.success,
    required this.questions,
    required this.count,
  });

  factory OnboardingQuestionsResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingQuestionsResponse(
      success: json['success'] ?? false,
      questions: (json['data'] as List<dynamic>?)
          ?.map((q) => OnboardingQuestion.fromJson(q))
          .toList() ?? [],
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [success, questions, count];
}

class OnboardingAnswersResponse extends Equatable {
  final bool success;
  final String message;
  final List<AnswerData> data;
  final int count;

  const OnboardingAnswersResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.count,
  });

  factory OnboardingAnswersResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingAnswersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((d) => AnswerData.fromJson(d))
          .toList() ?? [],
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [success, message, data, count];
}

class AnswerData extends Equatable {
  final String action;
  final OnboardingAnswer answer;

  const AnswerData({
    required this.action,
    required this.answer,
  });

  factory AnswerData.fromJson(Map<String, dynamic> json) {
    return AnswerData(
      action: json['action'] ?? '',
      answer: OnboardingAnswer.fromJson(json['answer'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [action, answer];
}
