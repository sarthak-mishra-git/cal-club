import 'package:equatable/equatable.dart';

class MealDetailsModel extends Equatable {
  final String id;
  final String name;
  final String? mealType;
  final String imageUrl;
  final NutritionalSummary nutritionalSummary;
  final List<IngredientItem> ingredients;
  final String balanceMessage;
  final bool isBalanced;
  final int version;

  const MealDetailsModel({
    required this.id,
    required this.name,
    this.mealType,
    required this.imageUrl,
    required this.nutritionalSummary,
    required this.ingredients,
    required this.balanceMessage,
    required this.isBalanced,
    required this.version,
  });

  factory MealDetailsModel.fromJson(Map<String, dynamic> json) {
    return MealDetailsModel(
      id: json['mealId'] ?? json['id'] ?? '',
      name: json['mealName'] ?? json['name'] ?? '',
      mealType: json['mealType'] ?? '',
      imageUrl: json['imagePath'] ?? json['imageUrl'] ?? '',
      nutritionalSummary: NutritionalSummary.fromJson(json['nutritionalSummary'] ?? {}),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => IngredientItem.fromJson(e))
              .toList() ??
          [],
      balanceMessage: json['balanceMessage'] ?? '',
      isBalanced: json['isBalanced'] ?? false,
      version: _parseVersion(json['version']),
    );
  }

  static int _parseVersion(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        // Handle version strings like "1.0.0" -> extract major version
        final parts = value.split('.');
        if (parts.isNotEmpty) {
          return int.parse(parts[0]);
        }
        return int.parse(value);
      } catch (e) {
        return 1;
      }
    }
    return 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'nutritionalSummary': nutritionalSummary.toJson(),
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'balanceMessage': balanceMessage,
      'isBalanced': isBalanced,
      'version': version,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        nutritionalSummary,
        ingredients,
        balanceMessage,
        isBalanced,
        version,
      ];
}

class NutritionalSummary extends Equatable {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const NutritionalSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory NutritionalSummary.fromJson(Map<String, dynamic> json) {
    return NutritionalSummary(
      totalCalories: (json['calories'] ?? json['totalCalories'] ?? 0).toDouble(),
      totalProtein: (json['protein'] ?? json['totalProtein'] ?? 0).toDouble(),
      totalCarbs: (json['carbs'] ?? json['totalCarbs'] ?? 0).toDouble(),
      totalFat: (json['fats'] ?? json['totalFat'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }

  @override
  List<Object?> get props => [totalCalories, totalProtein, totalCarbs, totalFat];
}

class IngredientItem extends Equatable {
  final String itemId;
  final String name;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String imageUrl;

  const IngredientItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.imageUrl,
  });

  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    return IngredientItem(
      itemId: json['itemId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: _parseQuantity(json['quantity']),
      unit: json['unit'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  static double _parseQuantity(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'imageUrl': imageUrl,
    };
  }

  IngredientItem copyWith({
    String? itemId,
    String? name,
    double? quantity,
    String? unit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? imageUrl,
  }) {
    return IngredientItem(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        itemId,
        name,
        quantity,
        unit,
        calories,
        protein,
        carbs,
        fat,
        imageUrl,
      ];
} 