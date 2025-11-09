import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Timer? _focusTimer;

  @override
  void initState() {
    super.initState();
    // Set up focus listeners to prevent rapid focus changes
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          // Cancel any pending focus timer
          _focusTimer?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      final otp = _otpControllers.map((c) => c.text).join();
      context.read<AuthBloc>().add(
        VerifyOtpRequested(
          phoneNumber: widget.phoneNumber,
          otp: otp,
        ),
      );
    }
  }

  void _onOtpChanged(String value, int index) {
    // Cancel any pending focus timer
    _focusTimer?.cancel();
    
    if (value.length == 1 && index < 5) {
      // Move to next field after a short delay
      _focusTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNodes[index + 1].requestFocus();
        }
      });
    } else if (value.isEmpty && index > 0) {
      // Move to previous field after a short delay
      _focusTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNodes[index - 1].requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigate to dashboard
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/dashboard',
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            _isLoading = state is VerifyingOtp;
            
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Phone Icon
                        Icon(
                          Icons.phone_android,
                          size: 80,
                          color: Colors.black, // Dark beige
                        ),
                        const SizedBox(height: 24),
                        
                        // Title
                        Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        Text(
                          'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // OTP Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                            (index) => SizedBox(
                              width: 50,
                              child: TextFormField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                textInputAction: index == 5 ? TextInputAction.done : TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.black), // Dark beige
                                  ),
                                ),
                                onChanged: (value) => _onOtpChanged(value, index),
                                onFieldSubmitted: (value) {
                                  if (index < 5 && value.isNotEmpty) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (index == 5) {
                                    _verifyOtp();
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Verify Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Dark beige
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Resend OTP
                        TextButton(
                          onPressed: _isLoading ? null : () {
                            context.read<AuthBloc>().add(
                              SendOtpRequested(phoneNumber: widget.phoneNumber),
                            );
                          },
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: Colors.black, // Dark beige
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 