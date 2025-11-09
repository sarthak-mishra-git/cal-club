import 'package:equatable/equatable.dart';

class OnboardingAnswer extends Equatable {
  final String id;
  final String userId;
  final String questionId;
  final List<String> values;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  const OnboardingAnswer({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.values,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OnboardingAnswer.fromJson(Map<String, dynamic> json) {
    return OnboardingAnswer(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      questionId: json['questionId'] is Map<String, dynamic> 
          ? json['questionId']['_id'] ?? ''
          : json['questionId'] ?? '',
      values: List<String>.from(json['values'] ?? []),
      deletedAt: json['deletedAt'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'values': values,
    };
  }

  @override
  List<Object?> get props => [id, userId, questionId, values, deletedAt, createdAt, updatedAt];
}
