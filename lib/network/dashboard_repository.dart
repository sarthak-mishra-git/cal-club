import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/screens/dashboard_screen_model.dart';
import '../utils/network_logger.dart';
import '../network/token_storage.dart';

class DashboardRepository {
  static const String _baseUrl = 'https://cal-club.onrender.com';

  Future<DashboardScreenModel> fetchDashboardScreenModel({String? date}) async {
    try {
      // Get the stored token
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Use current date if none provided
      final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      
      final url = Uri.parse('$_baseUrl/app/calendar?date=$targetDate');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      NetworkLogger.logRequest('GET', url.toString(), headers, '');

      final response = await http.get(url, headers: headers);
      
      NetworkLogger.logResponse('GET', url.toString(), response.statusCode, response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return DashboardScreenModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('GET', '$_baseUrl/app/calendar', e.toString());
      rethrow;
    }
  }
} 