import 'package:flutter/material.dart';

class MacroCardData {
  final String icon;
  final String color;
  final String text;
  final double value;
  final double completed;
  final double target;

  MacroCardData({
    required this.icon,
    required this.color,
    required this.text,
    required this.value,
    required this.completed,
    required this.target,
  });

  factory MacroCardData.fromJson(Map<String, dynamic> json) => MacroCardData(
        icon: json['icon'] ?? '',
        color: json['color'] ?? '#000000',
        text: json['text'] ?? '',
        value: (json['value'] ?? 0).toDouble(),
        completed: (json['completed'] ?? 0).toDouble(),
        target: (json['target'] ?? 0).toDouble(),
      );

  Color get colorValue {
    switch (color.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'brown':
        return Colors.brown;
      case 'blue':
        return Colors.blue;
      case 'black':
        return Colors.black;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  double get progressPercentage {
    if (target == 0) return 0.0;
    return (completed / target).clamp(0.0, 1.0);
  }
} 