class AppBarData {
  final String title;
  final String icon;
  final int? streak;

  AppBarData({
    required this.title,
    required this.icon,
    this.streak,
  });

  factory AppBarData.fromJson(Map<String, dynamic> json) => AppBarData(
        title: json['title'] ?? '',
        icon: json['icon'] ?? '',
        streak: json['streak'],
      );
}
