class DayData {
  final String dayLetter;
  final int date;
  final bool isSelected;

  DayData({
    required this.dayLetter,
    required this.date,
    required this.isSelected,
  });

  factory DayData.fromJson(Map<String, dynamic> json) => DayData(
        dayLetter: json['dayLetter'] ?? '',
        date: json['date'] ?? 0,
        isSelected: json['isSelected'] ?? false,
      );
}

class WeekViewData {
  final List<DayData> days;

  WeekViewData({
    required this.days,
  });

  factory WeekViewData.fromJson(Map<String, dynamic> json) => WeekViewData(
        days: (json['days'] as List<dynamic>?)
                ?.map((day) => DayData.fromJson(day as Map<String, dynamic>))
                .toList() ??
            [],
      );
} 