class LogEntryData {
  final String mealId;
  final String dishImage;
  final String dishName;
  final String time;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  LogEntryData({
    required this.mealId,
    required this.dishImage,
    required this.dishName,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory LogEntryData.fromJson(Map<String, dynamic> json) => LogEntryData(
        mealId: json['mealId'] ?? '',
        dishImage: json['dish_image'] ?? '',
        dishName: json['dish_name'] ?? '',
        time: json['time'] ?? '',
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
      );
} 