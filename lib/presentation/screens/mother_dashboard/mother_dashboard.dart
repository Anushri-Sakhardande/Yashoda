import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yashoda/presentation/screens/appointment/search_admin.dart';
import '../../widgets/custom_app_bar.dart';
import '../appointment/book_appointment.dart';
import '../health_status/health_status_update.dart';
import '../../widgets/health_update_banner.dart';
import '../../widgets/health_circle.dart';
import '../appointment/upcoming_appointments.dart';
import '../../widgets/reminders_card.dart';
import '../community_chat/group_chat_screen.dart'; // ✅ Community chat import

class MotherDashboard extends StatelessWidget {
  final dynamic userProfile;

  MotherDashboard({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Your Well-being Dashboard",
        uid: userProfile["uid"],
        userProfile: userProfile,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HealthStatusBanner(userId: userProfile["uid"]),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${userProfile["name"]}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We're here to support you on your journey. ",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("health_status")
                  .doc(userProfile["uid"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var healthData = snapshot.data!.data() as Map<String, dynamic>?;

                if (healthData == null) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "No health data available.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return Center(
                  child: HealthStatusCircle(
                    healthData: healthData,
                    centerText: "Postpartum Care",
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HealthStatusScreen(userId: userProfile["uid"]),
                  ),
                );
              },
              child: Text("Update Health Status"),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Upcoming Appointments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 150,
              child: UpcomingAppointmentsScreen(
                userId: userProfile["uid"],
                isAdmin: false,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (userProfile.exists && userProfile.data()?.containsKey("assignedAdmin") == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookAppointmentScreen(
                        userId: userProfile["uid"],
                        adminId: userProfile["assignedAdmin"],
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchAdminScreen(
                        userUID: userProfile["uid"],
                      ),
                    ),
                  );
                }
              },
              child: Text("Book Appointment"),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Your Reminders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 200,
              child: RemindersCard(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to mental health support resources
                    },
                    child: Text("Mental Health & Wellness"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChatScreen(groupName: "mother"),
                        ),
                      );
                    },
                    child: Text("Community Support Groups"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to self-care tips
                    },
                    child: Text("Self-Care & Wellness"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
