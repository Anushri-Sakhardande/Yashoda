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
import '../../widgets/health_graph.dart';
import '../community_chat/group_chat_screen.dart';
import '../mental_health/MentalHealthScreen.dart';
import '../selfcare/SelfCareScreen.dart';

class MiscarriedDashboard extends StatelessWidget {
  final dynamic userProfile;

  MiscarriedDashboard({required this.userProfile});

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

            SingleChildScrollView(
              child: Expanded(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(userProfile["uid"])
                          .collection("healthStatusEntries")
                          .orderBy("lastUpdated", descending: true)
                          .limit(1) // Only fetch the most recent entry
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "No health data available.",
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        var latestHealthData =
                        snapshot.data!.docs.first.data() as Map<
                            String,
                            dynamic>;

                        return Center(
                          child: HealthStatusCircle(
                            healthData: latestHealthData,
                            centerText: "Your Journey",
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 10),

                    HealthLineChart(userId: userProfile["uid"]),

                    // Navigate to Health Status Update
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                HealthStatusScreen(
                                  userId: userProfile["uid"],
                                ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      height: 150, // Define height to prevent layout issues
                      child: UpcomingAppointmentsScreen(
                        userId: userProfile["uid"],
                        isAdmin:
                        false, // Change to true if it's an admin dashboard
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (userProfile.exists && userProfile
                            .data()
                            ?.containsKey("assignedAdmin") == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  BookAppointmentScreen(
                                    userId: userProfile["uid"],
                                    adminId: userProfile["assignedAdmin"],
                                  ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  SearchAdminScreen(
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 200, // Define height to prevent layout issues
                      child: RemindersCard(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to mental health support resources
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (
                                      context) => const MentalHealthScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.self_improvement),
                            label: Text("Mental Health & Wellness"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to community support groups
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GroupChatScreen(groupName: "miscarried",userName: userProfile['name']),
                                ),
                              );
                            },
                            child: Text("Community Support Groups"),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to self-care tips
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelfCareScreen(
                                    userProfile: userProfile,
                                  ),
                                ),
                              );
                            },
                            child: Text("Self-Care"),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                      SearchAdminScreen(
                                        userUID: userProfile["uid"],
                                      ),
                                ),
                              );
                            },
                            child: Text("Assign Health Administrator"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
