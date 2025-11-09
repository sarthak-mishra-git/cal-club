import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const SendOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const VerifyOtpRequested({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class LogoutRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {
  final String phoneNumber;

  const DeleteAccountRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class EnterAsGuest extends AuthEvent {}

class ExitGuestMode extends AuthEvent {} 