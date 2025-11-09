import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/subscription_repository.dart';
import '../../services/payment_service.dart';
import '../../models/payment/plan_model.dart';
import '../../models/payment/subscription_model.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  final PaymentService _paymentService;
  Timer? _pollingTimer;
  Timer? _timeoutTimer;
  String? _currentSubscriptionId;

  SubscriptionBloc({
    required SubscriptionRepository repository,
    required PaymentService paymentService,
  }) : _repository = repository,
       _paymentService = paymentService,
       super(SubscriptionInitial()) {
    
    on<LoadPlans>(_onLoadPlans);
    on<CreateSubscription>(_onCreateSubscription);
    on<CheckSubscriptionStatus>(_onCheckSubscriptionStatus);
    on<PaymentSuccessEvent>(_onPaymentSuccess);
    on<PaymentErrorEvent>(_onPaymentError);
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);

    // Set up payment service callbacks
    _paymentService.onPaymentSuccess = (response) {
      add(PaymentSuccessEvent(
        paymentId: response.paymentId!,
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      ));
    };

    _paymentService.onPaymentError = (response) {
      add(PaymentErrorEvent(response.message ?? 'Payment failed'));
    };
  }

  Future<void> _onLoadPlans(
    LoadPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    
    try {
      final response = await _repository.getPlans();
      emit(PlansLoaded(response.plans));
    } catch (e) {
      emit(SubscriptionError('Failed to load plans: $e'));
    }
  }

  Future<void> _onCreateSubscription(
    CreateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    
    try {
      final response = await _repository.createSubscription(event.externalPlanId);
      _currentSubscriptionId = response.subscription.id; // Store subscription ID
      emit(SubscriptionCreated(response.subscription));
      
      // Open Razorpay payment
      _paymentService.openSubscriptionPayment(
        response.externalSubscriptionId,
        planId: event.externalPlanId,
      );
      emit(PaymentProcessing(response.subscription.id));
    } catch (e) {
      emit(SubscriptionError('Failed to create subscription: $e'));
    }
  }

  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final response = await _repository.getSubscription(event.subscriptionId);
      
      if (response.subscription.status == 'active') {
        emit(SubscriptionActive(response.subscription));
        add(StopPolling());
      } else if (response.subscription.status == 'failed') {
        emit(SubscriptionError('Subscription failed'));
        add(StopPolling());
      }
      // Continue polling if status is 'created' or 'processing'
    } catch (e) {
      emit(SubscriptionError('Failed to check subscription status: $e'));
      add(StopPolling());
    }
  }

  void _onPaymentSuccess(
    PaymentSuccessEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(PaymentSuccessState(event.paymentId));
    
    // Start polling for subscription status if we have a subscription ID
    if (_currentSubscriptionId != null) {
      add(StartPolling(_currentSubscriptionId!));
    }
  }

  void _onPaymentError(
    PaymentErrorEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(PaymentErrorState(event.error));
  }

  void _onStartPolling(
    StartPolling event,
    Emitter<SubscriptionState> emit,
  ) {
    // Show waiting message
    emit(WaitingForActivation('Payment successful! Your subscription is being activated. This may take a few minutes...'));
    
    // Start polling every 5 seconds
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      add(CheckSubscriptionStatus(event.subscriptionId));
    });
    
    // Set 5-minute timeout
    _timeoutTimer = Timer(Duration(minutes: 5), () {
      add(StopPolling());
      add(PaymentErrorEvent('Subscription activation is taking longer than expected. Please check your subscription status later.'));
    });
  }

  void _onStopPolling(
    StopPolling event,
    Emitter<SubscriptionState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    emit(PollingStopped());
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _timeoutTimer?.cancel();
    _paymentService.dispose();
    return super.close();
  }
}
