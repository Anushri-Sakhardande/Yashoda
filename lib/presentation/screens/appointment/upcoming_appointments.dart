import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'feedback_appointment.dart';

class UpcomingAppointmentsScreen extends StatelessWidget {
  final String userId;
  final bool isAdmin;

  UpcomingAppointmentsScreen({required this.userId, required this.isAdmin});

  void _updateStatus(BuildContext context, String appointmentId, String status) {
    FirebaseFirestore.instance.collection("appointments").doc(appointmentId).update({
      "status": status,
      "updatedDateTime": DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Appointment $status")),
    );
  }

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

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No upcoming appointments."));
        }

        var appointments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            var appointment = appointments[index];
            String status = appointment["status"];
            DateTime dateTime = (appointment["proposedDateTime"]).toDate();

            return Card(
              margin: EdgeInsets.all(10),
              color: status == "Pending" ? Colors.orange.shade50 : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Purpose: ${appointment["purpose"]}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)}"),
                    if (appointment["reason"] != null && appointment["reason"].toString().isNotEmpty)
                      Text("Reason: ${appointment["reason"]}"),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            color: status == "Accepted" ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (status == "Pending" && isAdmin)
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () => _updateStatus(context, appointment.id, "Accepted"),
                              ),
                              IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => _updateStatus(context, appointment.id, "Rejected"),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (isAdmin && status == "Accepted" && dateTime.isBefore(DateTime.now())) ...[
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.edit),
                            label: Text("Update Health Feedback"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminFeedbackScreen(
                                    userId: appointment["userId"],
                                    appointmentId: appointment.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
