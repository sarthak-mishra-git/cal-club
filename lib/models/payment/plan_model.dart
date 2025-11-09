class Plan {
  final String id;
  final String title;
  final String description;
  final int duration;
  final String durationUnit;
  final String frequency;
  final String externalPlanId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plan({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.durationUnit,
    required this.frequency,
    required this.externalPlanId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      durationUnit: json['durationUnit'] ?? '',
      frequency: json['frequency'] ?? '',
      externalPlanId: json['external_plan_id'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'durationUnit': durationUnit,
      'frequency': frequency,
      'external_plan_id': externalPlanId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PlansResponse {
  final bool success;
  final List<Plan> plans;
  final int count;

  PlansResponse({
    required this.success,
    required this.plans,
    required this.count,
  });

  factory PlansResponse.fromJson(Map<String, dynamic> json) {
    return PlansResponse(
      success: json['success'] ?? false,
      plans: (json['plans'] as List<dynamic>?)
          ?.map((plan) => Plan.fromJson(plan))
          .toList() ?? [],
      count: json['count'] ?? 0,
    );
  }
}

