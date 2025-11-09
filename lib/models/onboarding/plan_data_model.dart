import 'package:equatable/equatable.dart';

class PlanData extends Equatable {
  final String? goal;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double? lbm; // Lean Body Mass in pounds (for g/lbm display)

  const PlanData({
    this.goal,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.lbm,
  });

  factory PlanData.fromJson(Map<String, dynamic> json) {
    return PlanData(
      goal: json['goal'] as String?,
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      lbm: json['lbm']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (goal != null) 'goal': goal,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      if (lbm != null) 'lbm': lbm,
    };
  }

  @override
  List<Object?> get props => [goal, calories, protein, fat, carbs, lbm];
}

