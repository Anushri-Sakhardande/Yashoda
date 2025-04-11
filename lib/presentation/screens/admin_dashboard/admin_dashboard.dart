import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../appointment/admin_appointment.dart';
import '../appointment/upcoming_appointments.dart';
//import '../announcement/announcement_card_section.dart';

class AdminDashboard extends StatefulWidget {
  final dynamic userProfile;

  const AdminDashboard({super.key, required this.userProfile});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _appointmentsExpanded = false;
  bool _announcementsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Health Admin Dashboard",
        uid: widget.userProfile["uid"],
        userProfile: widget.userProfile,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Direct Upcoming Appointments
            Text("Upcoming Appointments", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            SizedBox(
              height: 400, // adjust as needed
              child: UpcomingAppointmentsScreen(
                userId: widget.userProfile["uid"],
                isAdmin: true,
              ),
            ),
            SizedBox(height: 20),

            // Manage Appointments (Expandable)
            _buildExpandableCard(
              title: "Manage Appointments",
              expanded: _appointmentsExpanded,
              onExpandToggle: () => setState(() => _appointmentsExpanded = !_appointmentsExpanded),
              child: AdminAppointmentsScreen(adminId: widget.userProfile["uid"]),
            ),

            // // Announcements (Expandable)
            // _buildExpandableCard(
            //   title: "Announcements",
            //   expanded: _announcementsExpanded,
            //   onExpandToggle: () => setState(() => _announcementsExpanded = !_announcementsExpanded),
            //   child: AnnouncementCardSection(adminId: widget.userProfile["uid"]),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required bool expanded,
    required VoidCallback onExpandToggle,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: onExpandToggle,
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: child,
            ),
        ],
      ),
    );
  }
}
