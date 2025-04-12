import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yashoda/presentation/screens/appointment/search_admin.dart';
import '../../widgets/custom_app_bar.dart';
import '../appointment/book_appointment.dart';
import '../health_status/health_status_update.dart';
import '../../widgets/health_update_banner.dart';
import '../../widgets/health_circle.dart';
import '../appointment/upcoming_appointments.dart';
import '../../widgets/reminders_card.dart';
import '../community_chat/group_chat_screen.dart';
import '../../widgets/health_graph.dart';
import '../mental_health/MentalHealthScreen.dart';
import '../selfcare/SelfCareScreen.dart';

class PregnantDashboard extends StatefulWidget {
  final dynamic userProfile;

  PregnantDashboard({required this.userProfile});

  @override
  _PregnantDashboardState createState() => _PregnantDashboardState();
}

class _PregnantDashboardState extends State<PregnantDashboard> {

  Future<void> updateFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
        });
      }

      // Optional: listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': newToken,
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateFcmToken(); // <--- call it here
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Your Well-being Dashboard",
        uid: widget.userProfile["uid"],
        userProfile: widget.userProfile,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HealthStatusBanner(userId: widget.userProfile["uid"]),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${widget.userProfile["name"]}",
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
                          .doc(widget.userProfile["uid"])
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

                        var latestHealthData = snapshot.data!.docs.first.data()
                            as Map<String, dynamic>;

                        return Center(
                          child: HealthStatusCircle(
                            healthData: latestHealthData,
                            centerText:
                                "${widget.userProfile["pregnancyWeeks"]} Weeks of Pregnancy",
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 10),

                    HealthLineChart(userId: widget.userProfile["uid"]),

                    // Navigate to Health Status Update
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthStatusScreen(
                              userId: widget.userProfile["uid"],
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
                        userId: widget.userProfile["uid"],
                        isAdmin:
                            false, // Change to true if it's an admin dashboard
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        if (widget.userProfile.exists &&
                            widget.userProfile.data()?.containsKey("assignedAdmin") ==
                                true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookAppointmentScreen(
                                userId: widget.userProfile["uid"],
                                adminId: widget.userProfile["assignedAdmin"],
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchAdminScreen(
                                userUID: widget.userProfile["uid"],
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
                      width: 300, // Define height to prevent layout issues
                      child: RemindersCard(),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MentalHealthScreen(),
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
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupChatScreen(
                                    groupName: "pregnant",
                                    userName: widget.userProfile['name'],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.groups),
                            label: Text("Community Support Groups"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelfCareScreen(
                                    userProfile: widget.userProfile,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.spa),
                            label: Text("Self-Care"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchAdminScreen(
                                    userUID: widget.userProfile["uid"],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.admin_panel_settings),
                            label: Text("Assign Health Administrator"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    )

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
