class WeightProgress {
  final double? startWeight;
  final double? currentWeight;
  final double? targetWeight;
  final double? weightChangePerWeek;

  WeightProgress({
    this.startWeight,
    this.currentWeight,
    this.targetWeight,
    this.weightChangePerWeek,
  });

  factory WeightProgress.fromJson(Map<String, dynamic> json) => WeightProgress(
        startWeight: json['startWeight'] != null 
            ? (json['startWeight'] as num).toDouble()
            : null,
        currentWeight: json['currentWeight'] != null
            ? (json['currentWeight'] as num).toDouble()
            : null,
        targetWeight: json['targetWeight'] != null
            ? (json['targetWeight'] as num).toDouble()
            : null,
        weightChangePerWeek: json['weightChangePerWeek'] != null
            ? (json['weightChangePerWeek'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'startWeight': startWeight,
        'currentWeight': currentWeight,
        'targetWeight': targetWeight,
        'weightChangePerWeek': weightChangePerWeek,
      };
}

