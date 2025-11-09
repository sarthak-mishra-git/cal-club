class Subscription {
  final String id;
  final String externalSubscriptionId;
  final String externalPlanId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.externalSubscriptionId,
    required this.externalPlanId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      externalSubscriptionId: json['external_subscription_id'] ?? '',
      externalPlanId: json['external_plan_id'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'external_subscription_id': externalSubscriptionId,
      'external_plan_id': externalPlanId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateSubscriptionResponse {
  final bool success;
  final String message;
  final String externalSubscriptionId;
  final Subscription subscription;

  CreateSubscriptionResponse({
    required this.success,
    required this.message,
    required this.externalSubscriptionId,
    required this.subscription,
  });

  factory CreateSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      externalSubscriptionId: json['external_subscription_id'] ?? '',
      subscription: Subscription.fromJson(json['subscription'] ?? {}),
    );
  }
}

class GetSubscriptionResponse {
  final bool success;
  final Subscription subscription;

  GetSubscriptionResponse({
    required this.success,
    required this.subscription,
  });

  factory GetSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return GetSubscriptionResponse(
      success: json['success'] ?? false,
      subscription: Subscription.fromJson(json['subscription'] ?? {}),
    );
  }
}

