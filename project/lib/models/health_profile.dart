import 'package:cloud_firestore/cloud_firestore.dart';

class HealthProfile {
  final String id;
  final String? name;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weight; // in kg
  final double? height;
  final String? bloodGroup; // in cm
  final String fitnessGoal; // 'bodybuilding', 'weight_loss', 'general_health', 'endurance'
  final List<String> healthConditions;
  final List<String> remedies;
  final DateTime lastUpdated;

  HealthProfile({
    required this.id,
    this.name,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.height,
    this.bloodGroup,
    String? fitnessGoal,
    List<String>? healthConditions,
    List<String>? remedies,
    DateTime? lastUpdated,
  })  : fitnessGoal = fitnessGoal ?? 'general_health',
        healthConditions = healthConditions ?? <String>[],
        remedies = remedies ?? <String>[],
        lastUpdated = lastUpdated ?? DateTime.now();

  // Calculate BMI if weight/height are available
  double? get bmi {
    if (weight == null || height == null || height == 0) return null;
    final double meters = (height!) / 100.0;
    return weight! / (meters * meters);
  }

  // Get BMI category (null if BMI unavailable)
  String? get bmiCategory {
    final value = bmi;
    if (value == null) return null;
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Normal weight';
    if (value < 30) return 'Overweight';
    return 'Obese';
  }

  // Factory constructor to create a HealthProfile from a Firestore document
  factory HealthProfile.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HealthProfile(
      id: doc.id,
      name: data['name'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: data['gender'] as String?,
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      bloodGroup: data['bloodGroup'] as String?,
      fitnessGoal: data['fitnessGoal'] ?? 'general_health',
      healthConditions: List<String>.from(data['healthConditions'] ?? const []),
      remedies: List<String>.from(data['remedies'] ?? const []),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to convert a HealthProfile object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'weight': weight,
      'height': height,
      'bloodGroup': bloodGroup,
      'fitnessGoal': fitnessGoal,
      'healthConditions': healthConditions,
      'remedies': remedies,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
   // Method to easily create a copy of the profile with updated fields
  HealthProfile copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    double? height,
    String? bloodGroup,
    String? fitnessGoal,
    List<String>? healthConditions,
    List<String>? remedies,
    DateTime? lastUpdated,
  }) {
    return HealthProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      healthConditions: healthConditions ?? this.healthConditions,
      remedies: remedies ?? this.remedies,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
