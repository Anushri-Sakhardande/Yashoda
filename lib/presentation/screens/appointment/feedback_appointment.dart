import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/health_graph.dart'; // Assuming this is where your graph is
import 'feedback_history_appointment.dart'; // From previous step

class AdminFeedbackScreen extends StatefulWidget {
  final String userId;
  final String appointmentId;

  const AdminFeedbackScreen(
      {required this.userId, required this.appointmentId});

  @override
  _AdminFeedbackScreenState createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  late DocumentReference userRef;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  final _healthParams = {
    'haemoglobin': TextEditingController(),
    'bloodPressure': TextEditingController(),
    'sugar': TextEditingController(),
    'weight': TextEditingController(),
    'symptoms': TextEditingController(),
    'exerciseRoutine': TextEditingController(),
    'dietaryHabits': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId); // ✅ Initialize here
    _loadUserData();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _healthParams.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userSnapshot = await userRef.get();
    final data = userSnapshot.data() as Map<String, dynamic>;

    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      final timestamp = DateTime.now();

      final healthEntry = {
        "lastUpdated": timestamp,
        "haemoglobin": _healthParams["haemoglobin"]!.text,
        "bloodPressure": _healthParams["bloodPressure"]!.text,
        "sugar": _healthParams["sugar"]!.text,
        "weight": _healthParams["weight"]!.text,
        "symptoms": _healthParams["symptoms"]!.text,
        "exerciseRoutine": _healthParams["exerciseRoutine"]!.text,
        "dietaryHabits": _healthParams["dietaryHabits"]!.text,
      };

      final appointmentRef = FirebaseFirestore.instance
          .collection("appointments")
          .doc(widget.appointmentId);

      await appointmentRef.update({
        "feedback": _feedbackController.text,
      });

      await userRef.update({
        "healthStatusEntries": FieldValue.arrayUnion([healthEntry])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feedback & health updated")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Patient Health Update")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Health Update"),
        backgroundColor: Color(0xFFF4B860),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient: ${userData!["name"]}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            if (userData!["role"] == 'Pregnant') ...[
              Text("Weeks Pregnant: ${userData!["pregnancyWeeks"]}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ] else if (userData!["role"] == 'New Mother') ...[
              Text("Baby Months: ${userData!["babyMonths"]}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ] else ...[
              Text("Miscarried",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
            const SizedBox(height: 16),
            HealthLineChart(userId: widget.userId),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.history),
              label: Text("View Feedback History"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FeedbackHistoryScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text("Update Health Parameters",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  for (var entry in _healthParams.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextFormField(
                        controller: entry.value,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: entry.key[0].toUpperCase() +
                              entry.key.substring(1),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Required" : null,
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Doctor's Feedback (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitFeedback,
                    child: Text("Submit"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
