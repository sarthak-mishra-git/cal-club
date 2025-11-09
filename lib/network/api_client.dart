import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/navigation_service.dart';
import '../utils/network_logger.dart';
import '../network/token_storage.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class ApiClient {
  static const String _baseUrl = 'https://calclub.onrender.com';

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    NetworkLogger.logRequest('GET', url.toString(), requestHeaders, '');

    try {
      final response = await http.get(url, headers: requestHeaders);
      NetworkLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
      
      if (_isAuthError(response.statusCode)) {
        await _handleUnauthorizedError();
      }
      
      return response;
    } catch (e) {
      NetworkLogger.logError('GET', url.toString(), e.toString());
      rethrow;
    }
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    final requestBody = body != null ? json.encode(body) : null;
    NetworkLogger.logRequest('POST', url.toString(), requestHeaders, requestBody ?? '');

    try {
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: requestBody,
      );
      NetworkLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
      
      if (_isAuthError(response.statusCode)) {
        await _handleUnauthorizedError();
      }
      
      return response;
    } catch (e) {
      NetworkLogger.logError('POST', url.toString(), e.toString());
      rethrow;
    }
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    final requestBody = body != null ? json.encode(body) : null;
    NetworkLogger.logRequest('PUT', url.toString(), requestHeaders, requestBody ?? '');

    try {
      final response = await http.put(
        url,
        headers: requestHeaders,
        body: requestBody,
      );
      NetworkLogger.logResponse('PUT', url.toString(), response.statusCode, response.body);
      
      if (_isAuthError(response.statusCode)) {
        await _handleUnauthorizedError();
      }
      
      return response;
    } catch (e) {
      NetworkLogger.logError('PUT', url.toString(), e.toString());
      rethrow;
    }
  }

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    NetworkLogger.logRequest('DELETE', url.toString(), requestHeaders, '');

    try {
      final response = await http.delete(url, headers: requestHeaders);
      NetworkLogger.logResponse('DELETE', url.toString(), response.statusCode, response.body);
      
      if (_isAuthError(response.statusCode)) {
        await _handleUnauthorizedError();
      }
      
      return response;
    } catch (e) {
      NetworkLogger.logError('DELETE', url.toString(), e.toString());
      rethrow;
    }
  }

  static bool _isAuthError(int statusCode) {
    return isUnauthorizedError(statusCode);
  }

  static Future<void> _handleUnauthorizedError() async {
    await handleUnauthorizedError();
  }

  static Future<void> handleUnauthorizedError() async {
    // Clear the token from storage
    await TokenStorage.clearAuthData();
    
    // Try to dispatch logout event to AuthBloc
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      context.read<AuthBloc>().add(LogoutRequested());
    } else {
      // If context is not available, just navigate to login
      NavigationService.navigateToLogin();
    }
  }

  static bool isUnauthorizedError(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }
} 