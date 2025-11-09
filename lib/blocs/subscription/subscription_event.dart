import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlans extends SubscriptionEvent {}

class CreateSubscription extends SubscriptionEvent {
  final String externalPlanId;

  const CreateSubscription(this.externalPlanId);

  @override
  List<Object?> get props => [externalPlanId];
}

class CheckSubscriptionStatus extends SubscriptionEvent {
  final String subscriptionId;

  const CheckSubscriptionStatus(this.subscriptionId);

  @override
  List<Object?> get props => [subscriptionId];
}

class PaymentSuccessEvent extends SubscriptionEvent {
  final String paymentId;
  final String orderId;
  final String signature;

  const PaymentSuccessEvent({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  @override
  List<Object?> get props => [paymentId, orderId, signature];
}

class PaymentErrorEvent extends SubscriptionEvent {
  final String error;

  const PaymentErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class StartPolling extends SubscriptionEvent {
  final String subscriptionId;

  const StartPolling(this.subscriptionId);

  @override
  List<Object?> get props => [subscriptionId];
}

class StopPolling extends SubscriptionEvent {}
