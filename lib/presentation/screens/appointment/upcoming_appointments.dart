import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpcomingAppointmentsScreen extends StatelessWidget {
  final String userId;
  final bool isAdmin;

  UpcomingAppointmentsScreen({required this.userId, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("appointments")
          .where(isAdmin ? "adminId" : "userId", isEqualTo: userId)
          .where("status", whereIn: ["Pending", "Accepted"])
          .orderBy("proposedDateTime", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        var appointments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            var appointment = appointments[index];
            DateTime dateTime = (appointment["updatedDateTime"] ?? appointment["proposedDateTime"]).toDate();

            return Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text("Purpose: ${appointment["purpose"]}"),
                subtitle: Text("Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)}"),
                trailing: Text(
                  appointment["status"],
                  style: TextStyle(
                    color: appointment["status"] == "Accepted" ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
