import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:async';

class PaymentService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('=== PAYMENT ERROR ===');
    print('Code: ${response.code}');
    print('Message: ${response.message}');
    print('Error Details: ${response.error}');
    
    // Handle specific UPI errors
    if (response.message?.toLowerCase().contains('upi') == true) {
      print('UPI Payment Error: Please check your UPI ID or try a different payment method');
    }
    
    if (response.message?.toLowerCase().contains('phone') == true) {
      print('Phone Number Error: Please check your phone number format');
    }
    
    if (response.message?.toLowerCase().contains('invalid') == true) {
      print('Invalid Input Error: Please check your input format');
    }
    
    if (response.message?.toLowerCase().contains('gpay') == true || 
        response.message?.toLowerCase().contains('phonepe') == true) {
      print('UPI App Error: Try using a different UPI app or payment method');
    }
    
    onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    onExternalWallet?.call(response);
  }

  void openSubscriptionPayment(String subscriptionId, {String? planId}) {
    final options = {
      'key': const String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: 'rzp_test_RMmMizee4NVoem'),
      'subscription_id': subscriptionId,
      'name': 'Cal Club',
      'description': 'Premium Subscription',
      'prefill': {
        'email': 'user@example.com',
      },
      'method': {
        'netbanking': true,
        'card': true,
        'upi': true,
        'wallet': true,
      },
      'notes': {
        'payment_for': 'CalClub Pro Subscription'
      },
      'theme': {
        'color': '#F5F5DC'
      },
      'retry': {
        'enabled': true,
        'max_count': 3
      },
      'timeout': 120, // 2 minutes timeout
      'readonly': {
        'email': false,
        'contact': false
      },
      'modal': {
        'backdropclose': false,
        'escape': false,
        'handleback': false
      }
    };

    try {
      print('=== OPENING RAZORPAY PAYMENT ===');
      print('Subscription ID: $subscriptionId');
      print('Options: $options');
      _razorpay.open(options);
    } catch (e) {
      print('Error opening payment: $e');
      onPaymentError?.call(PaymentFailureResponse(
        0, // code
        'Failed to open payment: $e', // message
        {}, // error details
      ));
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
