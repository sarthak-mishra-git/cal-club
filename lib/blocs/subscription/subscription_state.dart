import 'package:equatable/equatable.dart';
import '../../models/payment/plan_model.dart';
import '../../models/payment/subscription_model.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class PlansLoaded extends SubscriptionState {
  final List<Plan> plans;

  const PlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class SubscriptionCreated extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionCreated(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class PaymentProcessing extends SubscriptionState {
  final String subscriptionId;

  const PaymentProcessing(this.subscriptionId);

  @override
  List<Object?> get props => [subscriptionId];
}

class PaymentSuccessState extends SubscriptionState {
  final String paymentId;

  const PaymentSuccessState(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class SubscriptionActive extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionActive(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentErrorState extends SubscriptionState {
  final String error;

  const PaymentErrorState(this.error);

  @override
  List<Object?> get props => [error];
}

class PollingStopped extends SubscriptionState {}

class WaitingForActivation extends SubscriptionState {
  final String message;

  const WaitingForActivation(this.message);

  @override
  List<Object?> get props => [message];
}
