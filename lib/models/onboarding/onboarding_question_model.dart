import 'package:equatable/equatable.dart';
import 'option_model.dart';
import 'plan_data_model.dart';

class QuestionImage extends Equatable {
  final String url;
  final double? paddingHorizontal;
  final double? paddingVertical;
  final double? height;

  const QuestionImage({
    required this.url,
    this.paddingHorizontal,
    this.paddingVertical,
    this.height,
  });

  factory QuestionImage.fromJson(Map<String, dynamic> json) {
    return QuestionImage(
      url: json['url'] ?? '',
      paddingHorizontal: json['paddingHorizontal']?.toDouble(),
      paddingVertical: json['paddingVertical']?.toDouble(),
      height: json['height']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (paddingHorizontal != null) 'paddingHorizontal': paddingHorizontal,
      if (paddingVertical != null) 'paddingVertical': paddingVertical,
      if (height != null) 'height': height,
    };
  }

  @override
  List<Object?> get props => [url, paddingHorizontal, paddingVertical, height];
}

class OnboardingQuestion extends Equatable {
  final String id;
  final String text;
  final String? subtext;
  final String type;
  final List<Option> options;
  final int sequence;
  final QuestionImage? image;
  final PlanData? planData;

  const OnboardingQuestion({
    required this.id,
    required this.text,
    this.subtext,
    required this.type,
    required this.options,
    required this.sequence,
    this.image,
    this.planData,
  });

  factory OnboardingQuestion.fromJson(Map<String, dynamic> json) {
    try {
      return OnboardingQuestion(
        id: json['_id'] ?? '',
        text: json['text'] ?? '',
        subtext: json['subtext'],
        type: json['type'] ?? '',
        options: (json['options'] as List<dynamic>?)
            ?.map((option) {
              if (option is! Map<String, dynamic>) {
                print('ERROR: Option is not Map<String, dynamic>: $option (type: ${option.runtimeType})');
                print('Question: ${json['text']}');
                return Option(text: option.toString());
              }
              return Option.fromJson(option);
            })
            .toList() ?? [],
        sequence: json['sequence'] ?? 0,
        image: json['image'] != null ? QuestionImage.fromJson(json['image']) : null,
        planData: json['planData'] != null ? PlanData.fromJson(json['planData']) : null,
      );
    } catch (e) {
      print('ERROR parsing question: ${json['text']}');
      print('Error: $e');
      print('Options: ${json['options']}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      if (subtext != null) 'subtext': subtext,
      'type': type,
      'options': options.map((option) => option.toJson()).toList(),
      'sequence': sequence,
      if (image != null) 'image': image!.toJson(),
      if (planData != null) 'planData': planData!.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, text, subtext, type, options, sequence, image, planData];
}
