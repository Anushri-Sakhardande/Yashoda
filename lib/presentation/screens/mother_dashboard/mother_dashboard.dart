import 'package:flutter/material.dart';

class MotherDashboard extends StatelessWidget {
  const MotherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mother's Dashboard")),
      body: Center(child: Text("Welcome to your dashboard, Mother!")),
    );
  }
}
