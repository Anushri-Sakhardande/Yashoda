import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../appointment/admin_appointment.dart';
import '../appointment/upcoming_appointments.dart';

class AdminDashboard extends StatefulWidget {
  final dynamic userProfile;

  const AdminDashboard({super.key, required this.userProfile});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Health Admin Dashboard",
        uid: widget.userProfile["uid"],
        userProfile: widget.userProfile,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Manage Appointments"),
              Tab(text: "Upcoming Appointments"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AdminAppointmentsScreen(adminId: widget.userProfile["uid"]),
                UpcomingAppointmentsScreen(userId: widget.userProfile["uid"], isAdmin: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
