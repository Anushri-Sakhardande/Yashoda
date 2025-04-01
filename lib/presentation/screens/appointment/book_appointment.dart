import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../data/models/appointment_model.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String userId;
  final String adminId; // Assigned admin

  BookAppointmentScreen({required this.userId, required this.adminId});

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDateTime;
  String selectedPurpose = "Routine Checkup";
  TextEditingController reasonController = TextEditingController();
  bool isLoading = false;

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute,
      );
    });
  }

  Future<void> _bookAppointment() async {
    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a date and time.")));
      return;
    }
    print(widget.userId);

    setState(() => isLoading = true);

    Appointment newAppointment = Appointment(
      id: "", // Firestore auto-generates an ID
      userId: widget.userId,
      adminId: widget.adminId,
      proposedDateTime: selectedDateTime!,
      updatedDateTime: null,
      status: "Pending",
      purpose: selectedPurpose,
      reason: reasonController.text,
    );

    await FirebaseFirestore.instance.collection("appointments").add(newAppointment.toFirestore());

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Appointment")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Purpose"),
            DropdownButton<String>(
              value: selectedPurpose,
              items: ["Routine Checkup", "Inoculation", "Other"].map((purpose) {
                return DropdownMenuItem(value: purpose, child: Text(purpose));
              }).toList(),
              onChanged: (value) => setState(() => selectedPurpose = value!),
            ),
            SizedBox(height: 20),
            Text("Select Date & Time"),
            TextButton(
              onPressed: _pickDateTime,
              child: Text(
                selectedDateTime == null
                    ? "Pick Date & Time"
                    : DateFormat("yyyy-MM-dd hh:mm a").format(selectedDateTime!),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(labelText: "Reason (Optional)"),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _bookAppointment,
              child: Text("Book Appointment"),
            ),
          ],
        ),
      ),
    );
  }
}
