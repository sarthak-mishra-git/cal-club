import 'package:equatable/equatable.dart';
import '../../models/auth/auth_response_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSending extends AuthState {}

class OtpSent extends AuthState {}

class VerifyingOtp extends AuthState {}

class Authenticated extends AuthState {
  final String token;
  final UserModel user;

  const Authenticated({
    required this.token,
    required this.user,
  });

  @override
  List<Object?> get props => [token, user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DeletingAccount extends AuthState {}

class AccountDeleted extends AuthState {
  final String message;

  const AccountDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class GuestAuthenticated extends AuthState {} 