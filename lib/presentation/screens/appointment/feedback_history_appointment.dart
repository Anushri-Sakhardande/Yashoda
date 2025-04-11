import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FeedbackHistoryScreen extends StatelessWidget {
  final String userId;

  const FeedbackHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Previous Feedbacks"),backgroundColor: Color(0xFFF4B860),),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("appointments")
            .where("userId", isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No feedback available yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final dateTime = (doc["proposedDateTime"] as Timestamp).toDate();
              final formattedDate = DateFormat("yyyy-MM-dd hh:mm a").format(dateTime);
              final data = doc.data() as Map<String, dynamic>;
              final feedback = data.containsKey("feedback") ? data["feedback"] : "No feedback";
              final adminId = doc["adminId"] ?? "Unknown";

              return Card(
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text("Date: $formattedDate"),
                  subtitle: Text("Doctor ID: $adminId"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(feedback),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
