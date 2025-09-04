import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_details/meal_details_model.dart';
import '../utils/network_logger.dart';

class FoodAnalysisRepository {
  static const String _baseUrl = 'https://cal-club.onrender.com';

  Future<MealDetailsModel> analyzeFoodImage(String imageUrl, {String? token}) async {
    final url = Uri.parse('$_baseUrl/ai/food-calories');
    
    // Fix request body format to match API
    final body = json.encode({
      'url': imageUrl,
      'provider': 'openai'
    });

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add Authorization header if token is provided
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    NetworkLogger.logRequest('POST', url.toString(), headers, body);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return MealDetailsModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to analyze food image: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }

  Future<MealDetailsModel> updateIngredientQuantity({
    required String mealId,
    required String itemId,
    required double newQuantity,
    required String newItem,
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl/meals/update');
    
    final body = json.encode({
      'mealId': mealId,
      'itemId': itemId,
      'newQuantity': newQuantity,
      'newItem': newItem,
    });

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add Authorization header if token is provided
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    NetworkLogger.logRequest('POST', url.toString(), headers, body);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return MealDetailsModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to update ingredient quantity: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }

  Future<MealDetailsModel> getMealDetails(String mealId, {String? token}) async {
    final url = Uri.parse('$_baseUrl/meals/$mealId');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add Authorization header if token is provided
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    NetworkLogger.logRequest('GET', url.toString(), headers, '');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      NetworkLogger.logResponse('GET', url.toString(), response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return MealDetailsModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch meal details: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('GET', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }
} 