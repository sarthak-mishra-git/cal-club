import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/food_analysis_repository.dart';
import '../../network/token_storage.dart';
import '../../models/meal_details/meal_details_model.dart';
import 'food_analysis_event.dart';
import 'food_analysis_state.dart';

class FoodAnalysisBloc extends Bloc<FoodAnalysisEvent, FoodAnalysisState> {
  final FoodAnalysisRepository _repository;

  FoodAnalysisBloc({FoodAnalysisRepository? repository})
      : _repository = repository ?? FoodAnalysisRepository(),
        super(FoodAnalysisInitial()) {
    on<AnalyzeFoodImage>(_onAnalyzeFoodImage);
    on<UpdateIngredientQuantity>(_onUpdateIngredientQuantity);
    on<FetchMealDetails>(_onFetchMealDetails);
    on<BulkEditIngredients>(_onBulkEditIngredients);
  }

  Future<void> _onAnalyzeFoodImage(
    AnalyzeFoodImage event,
    Emitter<FoodAnalysisState> emit,
  ) async {
    emit(FoodAnalysisLoading());
    
    try {
      // Get the stored token
      final token = await TokenStorage.getToken();
      if (token == null) {
        emit(FoodAnalysisError(message: 'No authentication token found'));
        return;
      }
      
      final mealDetails = await _repository.analyzeFoodImage(event.imageUrl, token: token);
      emit(FoodAnalysisLoaded(mealDetails: mealDetails));
    } catch (e) {
      emit(FoodAnalysisError(message: e.toString()));
    }
  }

  Future<void> _onUpdateIngredientQuantity(
    UpdateIngredientQuantity event,
    Emitter<FoodAnalysisState> emit,
  ) async {
    emit(FoodAnalysisUpdating());
    
    try {
      // Get the stored token
      final token = await TokenStorage.getToken();
      if (token == null) {
        emit(FoodAnalysisError(message: 'No authentication token found'));
        return;
      }
      
      final updatedMealDetails = await _repository.updateIngredientQuantity(
        mealId: event.mealId,
        itemId: event.itemId,
        newQuantity: event.newQuantity,
        newItem: event.newItem,
        token: token,
      );
      
      emit(FoodAnalysisUpdated(mealDetails: updatedMealDetails));
    } catch (e) {
      emit(FoodAnalysisError(message: 'Failed to update meal: $e'));
    }
  }

  Future<void> _onFetchMealDetails(
    FetchMealDetails event,
    Emitter<FoodAnalysisState> emit,
  ) async {
    emit(FoodAnalysisLoading());
    
    try {
      // Get the stored token
      final token = await TokenStorage.getToken();
      if (token == null) {
        emit(FoodAnalysisError(message: 'No authentication token found'));
        return;
      }
      
      final mealDetails = await _repository.getMealDetails(event.mealId, token: token);
      emit(FoodAnalysisLoaded(mealDetails: mealDetails));
    } catch (e) {
      emit(FoodAnalysisError(message: 'Failed to fetch meal details: $e'));
    }
  }

  Future<void> _onBulkEditIngredients(
    BulkEditIngredients event,
    Emitter<FoodAnalysisState> emit,
  ) async {
    emit(FoodAnalysisUpdating());
    
    try {
      // Get the stored token
      final token = await TokenStorage.getToken();
      if (token == null) {
        emit(FoodAnalysisError(message: 'No authentication token found'));
        return;
      }
      
      final updatedMealDetails = await _repository.bulkEditIngredients(
        mealId: event.mealId,
        items: event.items,
        token: token,
      );
      
      emit(FoodAnalysisUpdated(mealDetails: updatedMealDetails));
    } catch (e) {
      emit(FoodAnalysisError(message: 'Failed to bulk edit ingredients: $e'));
    }
  }
} 