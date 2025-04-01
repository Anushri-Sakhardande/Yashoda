import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String userId;
  final String adminId;
  final DateTime proposedDateTime;
  final DateTime? updatedDateTime;
  final String status; // "Pending", "Accepted", "Rejected"
  final String purpose; // "Routine Checkup", "Inoculation", "Other"
  final String reason;

  Appointment({
    required this.id,
    required this.userId,
    required this.adminId,
    required this.proposedDateTime,
    this.updatedDateTime,
    required this.status,
    required this.purpose,
    this.reason = "",
  });

  // Convert Firestore document to an Appointment object
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      userId: data["userId"],
      adminId: data["adminId"],
      proposedDateTime: (data["proposedDateTime"] as Timestamp).toDate(),
      updatedDateTime: data["updatedDateTime"] != null
          ? (data["updatedDateTime"] as Timestamp).toDate()
          : null,
      status: data["status"],
      purpose: data["purpose"],
      reason: data["reason"] ?? "",
    );
  }

  // Convert Appointment object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      "userId": userId,
      "adminId": adminId,
      "proposedDateTime": proposedDateTime,
      "updatedDateTime": updatedDateTime,
      "status": status,
      "purpose": purpose,
      "reason": reason,
    };
  }
}
