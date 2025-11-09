class DaySelectorData {
  final String dayText;
  final bool prev;
  final bool next;
  final String date;

  DaySelectorData({
    required this.dayText,
    required this.prev,
    required this.next,
    required this.date,
  });

  factory DaySelectorData.fromJson(Map<String, dynamic> json) => DaySelectorData(
        dayText: json['dayText'] ?? '',
        prev: json['prev'] ?? false,
        next: json['next'] ?? false,
        date: json['date'] ?? '',
      );
}

