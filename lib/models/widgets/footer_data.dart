class FooterItemData {
  final bool active;
  final String icon;
  final String title;
  final String action;

  FooterItemData({
    required this.active,
    required this.icon,
    required this.title,
    required this.action,
  });

  factory FooterItemData.fromJson(Map<String, dynamic> json) => FooterItemData(
        active: json['active'] ?? false,
        icon: json['icon'] ?? '',
        title: json['title'] ?? '',
        action: json['action'] ?? '',
      );
}
