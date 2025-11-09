import 'package:equatable/equatable.dart';
import 'progress_model.dart';
import '../screens/progress_screen_model.dart';

class ProgressResponse extends Equatable {
  final bool success;
  final String? message;
  final ProgressScreenModel data;
  final int? count;

  const ProgressResponse({
    required this.success,
    this.message,
    required this.data,
    this.count,
  });

  factory ProgressResponse.fromJson(Map<String, dynamic> json) {
    return ProgressResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: ProgressScreenModel.fromJson(json['data'] ?? {}),
      count: json['count'],
    );
  }

  @override
  List<Object?> get props => [success, message, data, count];
}

class ProgressListResponse extends Equatable {
  final bool success;
  final String? message;
  final List<ProgressData> data;
  final int count;

  const ProgressListResponse({
    required this.success,
    this.message,
    required this.data,
    required this.count,
  });

  factory ProgressListResponse.fromJson(Map<String, dynamic> json) {
    return ProgressListResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          ?.map((d) => ProgressData.fromJson(d))
          .toList() ?? [],
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [success, message, data, count];
}

