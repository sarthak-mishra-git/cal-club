class DailyGoal {
  final double? calorie;
  final double? protein;
  final double? carbs;
  final double? fats;

  DailyGoal({
    this.calorie,
    this.protein,
    this.carbs,
    this.fats,
  });

  factory DailyGoal.fromJson(Map<String, dynamic> json) => DailyGoal(
        calorie: json['calorie'] != null
            ? (json['calorie'] as num).toDouble()
            : null,
        protein: json['protein'] != null
            ? (json['protein'] as num).toDouble()
            : null,
        carbs: json['carbs'] != null
            ? (json['carbs'] as num).toDouble()
            : null,
        fats: json['fats'] != null
            ? (json['fats'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'calorie': calorie,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
      };
}

