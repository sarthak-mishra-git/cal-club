import 'package:equatable/equatable.dart';

class Option extends Equatable {
  final String text;
  final String? subtext;
  final String? icon;

  const Option({
    required this.text,
    this.subtext,
    this.icon,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      text: json['text'] as String,
      subtext: json['subtext'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (subtext != null) 'subtext': subtext,
      if (icon != null) 'icon': icon,
    };
  }

  @override
  List<Object?> get props => [text, subtext, icon];
}

