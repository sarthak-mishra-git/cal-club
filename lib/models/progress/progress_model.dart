import 'package:equatable/equatable.dart';

class ProgressData extends Equatable {
  final String id;
  final String userId;
  final String date;
  final double? weight;
  final double? bodyFat;
  final double? muscleMass;
  final Map<String, dynamic>? measurements;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const ProgressData({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.bodyFat,
    this.muscleMass,
    this.measurements,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: json['date'] ?? '',
      weight: json['weight'] != null ? (json['weight'] is num ? json['weight'].toDouble() : double.tryParse(json['weight'].toString())) : null,
      bodyFat: json['bodyFat'] != null ? (json['bodyFat'] is num ? json['bodyFat'].toDouble() : double.tryParse(json['bodyFat'].toString())) : null,
      muscleMass: json['muscleMass'] != null ? (json['muscleMass'] is num ? json['muscleMass'].toDouble() : double.tryParse(json['muscleMass'].toString())) : null,
      measurements: json['measurements'] != null ? Map<String, dynamic>.from(json['measurements']) : null,
      notes: json['notes'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      if (weight != null) 'weight': weight,
      if (bodyFat != null) 'bodyFat': bodyFat,
      if (muscleMass != null) 'muscleMass': muscleMass,
      if (measurements != null) 'measurements': measurements,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, userId, date, weight, bodyFat, muscleMass, measurements, notes, createdAt, updatedAt];
}

