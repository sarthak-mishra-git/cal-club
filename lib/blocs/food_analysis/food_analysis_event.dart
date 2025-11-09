import 'package:equatable/equatable.dart';

abstract class FoodAnalysisEvent extends Equatable {
  const FoodAnalysisEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeFoodImage extends FoodAnalysisEvent {
  final String imageUrl;

  const AnalyzeFoodImage({required this.imageUrl});

  @override
  List<Object?> get props => [imageUrl];
}

class UpdateIngredientQuantity extends FoodAnalysisEvent {
  final String mealId;
  final String itemId;
  final double newQuantity;
  final String newItem;

  const UpdateIngredientQuantity({
    required this.mealId,
    required this.itemId,
    required this.newQuantity,
    required this.newItem,
  });

  @override
  List<Object?> get props => [mealId, itemId, newQuantity, newItem];
}

class FetchMealDetails extends FoodAnalysisEvent {
  final String mealId;

  const FetchMealDetails({required this.mealId});

  @override
  List<Object?> get props => [mealId];
}

class BulkEditIngredients extends FoodAnalysisEvent {
  final String mealId;
  final List<Map<String, dynamic>> items;

  const BulkEditIngredients({
    required this.mealId,
    required this.items,
  });

  @override
  List<Object?> get props => [mealId, items];
} 