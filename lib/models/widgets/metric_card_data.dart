class MetricCardData {
  final String title;
  final double value;
  final double? goal;
  final double? secondary;
  final double? tertiary;
  final String? secondaryLabel;
  final String? tertiaryLabel;
  final String? unit;

  MetricCardData({
    required this.title,
    required this.value,
    this.goal,
    this.secondary,
    this.tertiary,
    this.secondaryLabel,
    this.tertiaryLabel,
    this.unit,
  });

  factory MetricCardData.fromJson(Map<String, dynamic> json) => MetricCardData(
        title: json['title'] ?? '',
        value: (json['value'] ?? 0).toDouble(),
        goal: json['goal']?.toDouble(),
        secondary: json['secondary']?.toDouble(),
        tertiary: json['tertiary']?.toDouble(),
        secondaryLabel: json['secondaryLabel'],
        tertiaryLabel: json['tertiaryLabel'],
        unit: json['unit'],
      );
}
