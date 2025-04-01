import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../data/models/appointment_model.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  final String adminId;

  AdminAppointmentsScreen({required this.adminId});

  @override
  _AdminAppointmentsScreenState createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : {"name": "Unknown"};
  }

  Future<void> _updateAppointmentTime(String appointmentId, DateTime newTime) async {
    QuerySnapshot existingAppointments = await FirebaseFirestore.instance
        .collection("appointments")
        .where("adminId", isEqualTo: widget.adminId)
        .where("status", isEqualTo: "Accepted")
        .get();

    bool isClashing = existingAppointments.docs.any((doc) {
      DateTime existingTime = (doc["updatedDateTime"] ?? doc["proposedDateTime"]).toDate();
      return (existingTime.difference(newTime).inMinutes).abs() < 30;
    });

    if (isClashing) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Time slot already booked!")));
      return;
    }

    await FirebaseFirestore.instance.collection("appointments").doc(appointmentId).update({
      "updatedDateTime": newTime,
      "status": "Pending",
    });
  }

  Future<void> _acceptAppointment(String appointmentId) async {
    await FirebaseFirestore.instance.collection("appointments").doc(appointmentId).update({
      "status": "Accepted",
    });
  }

  Future<void> _rejectAppointment(String appointmentId) async {
    await FirebaseFirestore.instance.collection("appointments").doc(appointmentId).update({
      "status": "Rejected",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Appointments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("appointments")
            .where("adminId", isEqualTo: widget.adminId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var appointments = snapshot.data!.docs.map((doc) => Appointment.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              Appointment appointment = appointments[index];

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchUserData(appointment.userId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return SizedBox.shrink();

                  String applicantName = userSnapshot.data!["name"] ?? "Unknown";

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text("Applicant: $applicantName"),
                      subtitle: Text(
                        "Purpose: ${appointment.purpose}\n"
                            "Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(
                          appointment.updatedDateTime ?? appointment.proposedDateTime,
                        )}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () => _acceptAppointment(appointment.id),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectAppointment(appointment.id),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              DateTime? newTime = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (newTime != null) _updateAppointmentTime(appointment.id, newTime);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
