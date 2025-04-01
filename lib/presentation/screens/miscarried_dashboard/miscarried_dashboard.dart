import 'package:flutter/material.dart';
import 'package:yashoda/presentation/screens/appointment/search_admin.dart';
import '../../widgets/custom_app_bar.dart';
import '../appointment/book_appointment.dart';

class MiscarriedDashboard extends StatelessWidget {
  final dynamic userProfile;

  MiscarriedDashboard({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Your Well-being Dashboard", uid: userProfile["uid"], userProfile: userProfile),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${userProfile["name"]}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "We're here to support you on your journey. Take care of your well-being with these resources.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),

            // Support & Well-being Resources
            ElevatedButton(
              onPressed: () {
                // Navigate to mental health support resources
              },
              child: Text("Mental Health & Counseling"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to community support groups
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchAdminScreen(userUID: userProfile["uid"]),
                  ),
                );
              },
              child: Text("Assign Health Administrator"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookAppointmentScreen(userId: userProfile["uid"], adminId: userProfile["assignedAdmin"]),
                  ),
                );
              },
              child: Text("Book Appointment"),
            ),

          ],
        ),
      ),
    );
  }
}
