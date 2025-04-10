import 'package:cloud_firestore/cloud_firestore.dart';

class HealthStatusEntry {
  final String id;
  final double weight;
  final String bloodPressure;
  final double hemoglobin;
  final List<String> symptoms;
  final String exerciseRoutine;
  final String dietaryHabits;
  final DateTime timestamp;

  HealthStatusEntry({
    required this.id,
    required this.weight,
    required this.bloodPressure,
    required this.hemoglobin,
    required this.symptoms,
    required this.exerciseRoutine,
    required this.dietaryHabits,
    required this.timestamp,
  });

  factory HealthStatusEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthStatusEntry(
      id: doc.id,
      weight: (data['weight'] ?? 0).toDouble(),
      bloodPressure: data['bloodPressure'] ?? '',
      hemoglobin: (data['hemoglobin'] ?? 0).toDouble(),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      exerciseRoutine: data['exerciseRoutine'] ?? '',
      dietaryHabits: data['dietaryHabits'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "weight": weight,
      "bloodPressure": bloodPressure,
      "hemoglobin": hemoglobin,
      "symptoms": symptoms,
      "exerciseRoutine": exerciseRoutine,
      "dietaryHabits": dietaryHabits,
      "timestamp": Timestamp.fromDate(timestamp),
    };
  }
}
