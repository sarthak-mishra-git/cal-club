import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/onboarding/onboarding_response_model.dart';
import '../models/onboarding/onboarding_answer_model.dart';
import '../models/onboarding/plan_data_model.dart';
import '../utils/network_logger.dart';
import '../network/token_storage.dart';
import '../network/api_client.dart';

class OnboardingRepository {
  static const String _baseUrl = 'https://calclub.onrender.com';

  Future<OnboardingQuestionsResponse> fetchQuestions() async {
    final token = await TokenStorage.getToken();
    
    try {
      final response = await ApiClient.get(
        '/onboarding/questions',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return OnboardingQuestionsResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch questions: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('GET', '$_baseUrl/onboarding/questions', e.toString());
      throw Exception('Network error: $e');
    }
  }

  Future<OnboardingAnswersResponse> submitAnswers(List<OnboardingAnswer> answers) async {
    final url = Uri.parse('$_baseUrl/onboarding/answers');
    
    final token = await TokenStorage.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = json.encode({
      'answers': answers.map((answer) => answer.toJson()).toList(),
    });

    NetworkLogger.logRequest('POST', url.toString(), headers, body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to submit answers: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return OnboardingAnswersResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to submit answers: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }

  Future<List<OnboardingAnswer>> getExistingAnswers() async {
    final url = Uri.parse('$_baseUrl/onboarding/answers');
    
    final token = await TokenStorage.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    NetworkLogger.logRequest('GET', url.toString(), headers, '');

    try {
      final response = await http.get(url, headers: headers);
      NetworkLogger.logResponse('GET', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to fetch existing answers: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final getAnswersResponse = OnboardingGetAnswersResponse.fromJson(jsonResponse);
        return getAnswersResponse.data;
      } else {
        throw Exception('Failed to fetch existing answers: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('GET', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> calculateAndSaveGoals(Map<String, dynamic> goalData) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$_baseUrl/goals/calculate-and-save');
    final body = json.encode(goalData);

    NetworkLogger.logRequest('POST', url.toString(), {'Authorization': 'Bearer $token'}, body);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to calculate goals: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Failed to calculate goals: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to calculate goals: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfileGoals({
    double? dailyCalories,
    required double dailyProtein,
    required double dailyCarbs,
    required double dailyFats,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$_baseUrl/users/profile');
    final goalsMap = <String, dynamic>{
      'dailyProtein': dailyProtein.round(),
      'dailyCarbs': dailyCarbs.round(),
      'dailyFats': dailyFats.round(),
    };
    
    // Only include dailyCalories if provided
    // if (dailyCalories != null) {
    //   goalsMap['dailyCalories'] = dailyCalories.round();
    // }
    
    final body = json.encode({
      'goals': goalsMap,
    });

    NetworkLogger.logRequest('PATCH', url.toString(), {'Authorization': 'Bearer $token'}, body);

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      NetworkLogger.logResponse('PATCH', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to update profile goals: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to update profile goals: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('PATCH', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }
}
