import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final bool success;
  final String? token;
  final String? message;
  final String? phone;
  final String? otp;
  final UserModel? user;

  const AuthResponse({
    required this.success,
    this.token,
    this.message,
    this.phone,
    this.otp,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Check if this is a successful OTP request response
    if (json.containsKey('message') && json.containsKey('otp')) {
      return AuthResponse(
        success: true,
        message: json['message'],
        phone: json['phone'],
        otp: json['otp'],
      );
    }
    
    // Check if this is a successful OTP verification response
    if (json.containsKey('token')) {
      return AuthResponse(
        success: true,
        token: json['token'],
        message: json['message'],
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      );
    }
    
    // Error response
    return AuthResponse(
      success: false,
      message: json['error'] ?? json['message'] ?? 'Unknown error',
    );
  }

  @override
  List<Object?> get props => [success, token, message, phone, otp, user];
}

class UserModel extends Equatable {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [id, phoneNumber, name, email];
} 