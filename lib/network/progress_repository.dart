import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/progress/progress_response_model.dart';
import '../utils/network_logger.dart';
import '../network/token_storage.dart';
import '../network/api_client.dart';

class ProgressRepository {
  static const String _baseUrl = 'https://calclub.onrender.com';

  Future<ProgressResponse> fetchProgressData({String? date}) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$_baseUrl/app/progress');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    NetworkLogger.logRequest('GET', url.toString(), headers, '');

    try {
      final response = await http.get(url, headers: headers);
      NetworkLogger.logResponse('GET', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to fetch progress data: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ProgressResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch progress data: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('GET', url.toString(), e.toString());
      rethrow;
    }
  }

  Future<ProgressListResponse> fetchProgressHistory({String? startDate, String? endDate}) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$_baseUrl/app/progress/history')
        .replace(queryParameters: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    NetworkLogger.logRequest('GET', url.toString(), headers, '');

    try {
      final response = await http.get(url, headers: headers);
      NetworkLogger.logResponse('GET', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to fetch progress history: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ProgressListResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch progress history: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('GET', url.toString(), e.toString());
      rethrow;
    }
  }

  Future<ProgressResponse> createProgressData(Map<String, dynamic> progressData) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$_baseUrl/app/progress');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode(progressData);

    NetworkLogger.logRequest('POST', url.toString(), headers, body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to create progress data: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ProgressResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to create progress data: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      rethrow;
    }
  }

  Future<ProgressResponse> updateProgressData(String progressId, Map<String, dynamic> progressData) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$_baseUrl/app/progress/$progressId');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode(progressData);

    NetworkLogger.logRequest('PUT', url.toString(), headers, body);

    try {
      final response = await http.put(url, headers: headers, body: body);
      NetworkLogger.logResponse('PUT', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to update progress data: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ProgressResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to update progress data: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('PUT', url.toString(), e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addWeight({
    required double value,
    String unit = 'kg',
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$_baseUrl/user-logs');
    final body = json.encode({
      'type': 'WEIGHT',
      'value': value,
      'unit': unit,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    NetworkLogger.logRequest('POST', url.toString(), headers, body);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Failed to add weight: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to add weight: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      rethrow;
    }
  }
}

