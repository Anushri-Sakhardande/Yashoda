import 'package:cloud_firestore/cloud_firestore.dart';

class HealthStatus {
  final String userId;
  final double weight;
  final String bloodPressure;
  final double hemoglobin;
  final List<String> symptoms;
  final String exerciseRoutine;
  final String dietaryHabits;
  final DateTime lastUpdated;

  HealthStatus({
    required this.userId,
    required this.weight,
    required this.bloodPressure,
    required this.hemoglobin,
    required this.symptoms,
    required this.exerciseRoutine,
    required this.dietaryHabits,
    required this.lastUpdated,
  });

  // Convert Firestore document to HealthStatus model
  factory HealthStatus.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HealthStatus(
      userId: doc.id,
      weight: (data['weight'] ?? 0).toDouble(),
      bloodPressure: data['bloodPressure'] ?? '',
      hemoglobin: (data['hemoglobin'] ?? 0).toDouble(),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      exerciseRoutine: data['exerciseRoutine'] ?? '',
      dietaryHabits: data['dietaryHabits'] ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  // Convert HealthStatus model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "weight": weight,
      "bloodPressure": bloodPressure,
      "hemoglobin": hemoglobin,
      "symptoms": symptoms,
      "exerciseRoutine": exerciseRoutine,
      "dietaryHabits": dietaryHabits,
      "lastUpdated": Timestamp.fromDate(lastUpdated),
    };
  }
}
