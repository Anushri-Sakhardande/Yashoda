import 'package:cloud_firestore/cloud_firestore.dart';

class HealthStatusEntry {
  final String id;
  final double weight;
  final String bloodPressure;
  final double bloodSugar;
  final double hemoglobin;
  final List<String> symptoms;
  final String exerciseRoutine;
  final String dietaryHabits;
  final DateTime timestamp;
  final String feedback;

  HealthStatusEntry({
    required this.id,
    required this.weight,
    required this.bloodPressure,
    required this.bloodSugar,
    required this.hemoglobin,
    required this.symptoms,
    required this.exerciseRoutine,
    required this.dietaryHabits,
    required this.timestamp,
    required this.feedback,
  });

  factory HealthStatusEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthStatusEntry(
      id: doc.id,
      weight: (data['weight'] ?? 0).toDouble(),
      bloodPressure: data['bloodPressure'] ?? '',
      bloodSugar: (data['bloodSugar'] ?? 0).toDouble(),
      hemoglobin: (data['hemoglobin'] ?? 0).toDouble(),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      exerciseRoutine: data['exerciseRoutine'] ?? '',
      dietaryHabits: data['dietaryHabits'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      feedback: data['feedback'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "weight": weight,
      "bloodPressure": bloodPressure,
      "bloodSugar": bloodSugar,
      "hemoglobin": hemoglobin,
      "symptoms": symptoms,
      "exerciseRoutine": exerciseRoutine,
      "dietaryHabits": dietaryHabits,
      "timestamp": Timestamp.fromDate(timestamp),
      "feedback": feedback,
    };
  }
}
