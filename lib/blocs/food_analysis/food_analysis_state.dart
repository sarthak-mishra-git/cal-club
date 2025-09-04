import 'package:equatable/equatable.dart';
import '../../models/meal_details/meal_details_model.dart';

abstract class FoodAnalysisState extends Equatable {
  const FoodAnalysisState();

  @override
  List<Object?> get props => [];
}

class FoodAnalysisInitial extends FoodAnalysisState {}

class FoodAnalysisLoading extends FoodAnalysisState {}

class FoodAnalysisLoaded extends FoodAnalysisState {
  final MealDetailsModel mealDetails;

  const FoodAnalysisLoaded({required this.mealDetails});

  @override
  List<Object?> get props => [mealDetails];
}

class FoodAnalysisError extends FoodAnalysisState {
  final String message;

  const FoodAnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FoodAnalysisUpdating extends FoodAnalysisState {}

class FoodAnalysisUpdated extends FoodAnalysisState {
  final MealDetailsModel mealDetails;

  const FoodAnalysisUpdated({required this.mealDetails});

  @override
  List<Object?> get props => [mealDetails];
} 