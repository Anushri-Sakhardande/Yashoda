import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HealthStatusScreen extends StatefulWidget {
  final String userId;

  const HealthStatusScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _HealthStatusScreenState createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends State<HealthStatusScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _hemoglobinController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _exerciseRoutineController = TextEditingController();
  final TextEditingController _dietaryHabitsController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHealthStatus();
  }

  Future<void> _fetchHealthStatus() async {
    try {
      DocumentSnapshot healthStatusDoc = await FirebaseFirestore.instance
          .collection('health_status')
          .doc(widget.userId)
          .get();

      if (healthStatusDoc.exists) {
        Map<String, dynamic> data = healthStatusDoc.data() as Map<String, dynamic>;
        setState(() {
          _weightController.text = data['weight']?.toString() ?? '';
          _bloodPressureController.text = data['bloodPressure'] ?? '';
          _hemoglobinController.text = data['hemoglobin']?.toString() ?? '';
          _symptomsController.text = data['symptoms'] ?? '';
          _exerciseRoutineController.text = data['exerciseRoutine'] ?? '';
          _dietaryHabitsController.text = data['dietaryHabits'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching health status: $e");
    }
  }

  Future<void> _updateHealthStatus() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('health_status').doc(widget.userId).set({
          "userId": widget.userId,
          "weight": double.tryParse(_weightController.text) ?? 0.0,
          "bloodPressure": _bloodPressureController.text,
          "hemoglobin": double.tryParse(_hemoglobinController.text) ?? 0.0,
          "symptoms": _symptomsController.text,
          "exerciseRoutine": _exerciseRoutineController.text,
          "dietaryHabits": _dietaryHabitsController.text,
          "lastUpdated": Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Health status updated successfully!")));
      } catch (e) {
        print("Error updating health status: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update health status")));
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Health Status")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Weight (kg)"),
                validator: (value) => value!.isEmpty ? "Please enter weight" : null,
              ),
              TextFormField(
                controller: _bloodPressureController,
                decoration: InputDecoration(labelText: "Blood Pressure"),
                validator: (value) => value!.isEmpty ? "Please enter blood pressure" : null,
              ),
              TextFormField(
                controller: _hemoglobinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Hemoglobin (g/dL)"),
                validator: (value) => value!.isEmpty ? "Please enter hemoglobin level" : null,
              ),
              TextFormField(
                controller: _symptomsController,
                decoration: InputDecoration(labelText: "Symptoms"),
                validator: (value) => value!.isEmpty ? "Please enter any symptoms" : null,
              ),
              TextFormField(
                controller: _exerciseRoutineController,
                decoration: InputDecoration(labelText: "Exercise Routine"),
                validator: (value) => value!.isEmpty ? "Please enter exercise routine" : null,
              ),
              TextFormField(
                controller: _dietaryHabitsController,
                decoration: InputDecoration(labelText: "Dietary Habits"),
                validator: (value) => value!.isEmpty ? "Please enter dietary habits" : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _updateHealthStatus,
                child: Text("Update Health Status"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
