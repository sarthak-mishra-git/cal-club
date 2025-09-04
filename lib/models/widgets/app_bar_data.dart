class AppBarData {
  final String title;
  final String icon;
  final int caloriesBurnt;

  AppBarData({
    required this.title,
    required this.icon,
    required this.caloriesBurnt,
  });

  factory AppBarData.fromJson(Map<String, dynamic> json) => AppBarData(
        title: json['title'] ?? '',
        icon: json['icon'] ?? '',
        caloriesBurnt: json['caloriesBurnt'] ?? 0,
      );
}
