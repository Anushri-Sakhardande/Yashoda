import 'package:flutter/material.dart';

class PregnantDashboard extends StatelessWidget {
  const PregnantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pregnant mother's Dashboard")),
      body: Center(child: Text("Welcome to your dashboard, Mother!")),
    );
  }
}
