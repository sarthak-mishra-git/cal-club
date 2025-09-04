import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth/auth_response_model.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _phoneNumberKey = 'auth_phone_number';

  static Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> storeUser(UserModel user) async {
    final userJson = user.toJson();
    await _storage.write(key: _userKey, value: json.encode(userJson));
  }

  static Future<UserModel?> getUser() async {
    final userJsonString = await _storage.read(key: _userKey);
    if (userJsonString != null) {
      try {
        final userJson = json.decode(userJsonString);
        return UserModel.fromJson(userJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> storePhoneNumber(String phoneNumber) async {
    await _storage.write(key: _phoneNumberKey, value: phoneNumber);
  }

  static Future<String?> getPhoneNumber() async {
    return await _storage.read(key: _phoneNumberKey);
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>?> getAuthData() async {
    final token = await getToken();
    final user = await getUser();
    final phoneNumber = await getPhoneNumber();
    
    if (token != null) {
      return {
        'token': token,
        'user': user?.toJson(),
        'phoneNumber': phoneNumber,
      };
    }
    return null;
  }

  static Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _phoneNumberKey);
  }
} 