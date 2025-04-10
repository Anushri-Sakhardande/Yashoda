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

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _hemoglobinController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _exerciseRoutineController = TextEditingController();
  final TextEditingController _dietaryHabitsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _updateHealthStatus() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final entryData = {
          "weight": double.tryParse(_weightController.text) ?? 0.0,
          "bloodPressure": _bloodPressureController.text,
          "bloodSugar": double.tryParse(_bloodSugarController.text) ?? 0.0,
          "hemoglobin": double.tryParse(_hemoglobinController.text) ?? 0.0,
          "symptoms": _symptomsController.text.split(",").map((s) => s.trim()).toList(),
          "exerciseRoutine": _exerciseRoutineController.text,
          "dietaryHabits": _dietaryHabitsController.text,
          "lastUpdated": Timestamp.now(),
        };

        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .collection("healthStatusEntries")
            .add(entryData);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Health status added successfully!")));
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
      appBar: AppBar(title: Text("Add Health Status")),
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
                controller: _bloodSugarController,
                decoration: InputDecoration(labelText: "Blood Sugar"),
                validator: (value) => value!.isEmpty ? "Please enter blood sugar" : null,
              ),
              TextFormField(
                controller: _hemoglobinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Hemoglobin (g/dL)"),
                validator: (value) => value!.isEmpty ? "Please enter hemoglobin level" : null,
              ),
              TextFormField(
                controller: _symptomsController,
                decoration: InputDecoration(
                    labelText: "Symptoms",
                    hintText: "Separate multiple symptoms with commas"
                ),
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
                child: Text("Add Entry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
