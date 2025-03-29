import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class AdminDashboard extends StatelessWidget {
  final dynamic userProfile;

  const AdminDashboard({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Health Admin Dashboard", uid: userProfile["uid"], userProfile: userProfile),
      body: Center(
        child: Text("Manage Users & Send Notifications"),
      ),
    );
  }
}
