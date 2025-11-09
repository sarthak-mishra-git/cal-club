import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth/auth_response_model.dart';
import '../utils/network_logger.dart';
import '../network/api_client.dart';

class AuthRepository {
  static const String _baseUrl = 'https://calclub.onrender.com';

  Future<AuthResponse> requestOtp(String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/auth/request-otp');
    
    // Ensure phone number has country code prefix
    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
    
    final body = json.encode({'phone': formattedPhone});

    NetworkLogger.logRequest('POST', url.toString(), {'Content-Type': 'application/json'}, body);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = json.decode(response.body);
        return AuthResponse(
          success: false,
          message: errorResponse['error'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }

  Future<AuthResponse> verifyOtp(String phoneNumber, String otp) async {
    final url = Uri.parse('$_baseUrl/auth/verify-otp');
    
    // Ensure phone number has country code prefix
    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
    
    final body = json.encode({
      'phone': formattedPhone,
      'otp': otp,
    });

    NetworkLogger.logRequest('POST', url.toString(), {'Content-Type': 'application/json'}, body);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = json.decode(response.body);
        return AuthResponse(
          success: false,
          message: errorResponse['error'] ?? 'Invalid OTP',
        );
      }
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('$_baseUrl/auth/logout');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      // Don't throw error for logout, just log it
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String phoneNumber, {String? token}) async {
    final url = Uri.parse('$_baseUrl/users');
    
    // Ensure phone number has country code prefix
    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
    
    final body = json.encode({'phone': formattedPhone});

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add Authorization header if token is provided
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    NetworkLogger.logRequest('DELETE', url.toString(), headers, body);

    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: body,
      );

      NetworkLogger.logResponse('DELETE', url.toString(), response.statusCode, response.body);

      if (ApiClient.isUnauthorizedError(response.statusCode)) {
        await ApiClient.handleUnauthorizedError();
        throw Exception('Unauthorized: Token expired or invalid');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to delete account');
      }
    } catch (e) {
      NetworkLogger.logError('DELETE', url.toString(), e.toString());
      throw Exception('Network error: $e');
    }
  }
} 