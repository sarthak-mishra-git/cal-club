import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/auth_repository.dart';
import '../../network/token_storage.dart';
import '../../services/navigation_service.dart';
import '../../models/auth/auth_response_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final isAuthenticated = await TokenStorage.isAuthenticated();
      if (isAuthenticated) {
        final authData = await TokenStorage.getAuthData();
        if (authData != null) {
          final token = authData['token'] as String?;
          final userData = authData['user'] as Map<String, dynamic>?;
          
          if (token != null && userData != null) {
            final user = UserModel.fromJson(userData);
            emit(Authenticated(token: token, user: user));
            return;
          }
        }
      }
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(OtpSending());
    
    try {
      final response = await _repository.requestOtp(event.phoneNumber);
      if (response.success) {
        emit(OtpSent());
      } else {
        emit(AuthError(message: response.message ?? 'Failed to send OTP'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error sending OTP: $e'));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerifyingOtp());
    
    try {
      final response = await _repository.verifyOtp(event.phoneNumber, event.otp);
      if (response.success && response.token != null) {
        await TokenStorage.storeToken(response.token!);
        await TokenStorage.storePhoneNumber(event.phoneNumber);
        
        // Create a basic user model if user data is not provided
        UserModel user;
        if (response.user != null) {
          user = response.user!;
          await TokenStorage.storeUser(user);
        } else {
          // Create a basic user model with available data
          user = UserModel(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            phoneNumber: event.phoneNumber,
            name: null,
            email: null,
          );
          await TokenStorage.storeUser(user);
        }
        
        emit(Authenticated(token: response.token!, user: user));
      } else {
        emit(AuthError(message: response.message ?? 'Invalid OTP'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error verifying OTP: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    await TokenStorage.clearAuthData();
    emit(Unauthenticated());
    NavigationService.navigateToLogin();
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(DeletingAccount());
    
    try {
      // Get the stored token
      final token = await TokenStorage.getToken();
      if (token == null) {
        emit(AuthError(message: 'No authentication token found'));
        return;
      }
      
      // Call the delete account API
      final response = await _repository.deleteAccount(event.phoneNumber, token: token);
      
      // Clear all stored data
      await TokenStorage.clearAuthData();
      
      // Emit success state
      emit(AccountDeleted(message: response['message'] ?? 'Account deleted successfully'));
      
      // Navigate to login screen
      NavigationService.navigateToLogin();
    } catch (e) {
      emit(AuthError(message: 'Failed to delete account: $e'));
    }
  }
} 