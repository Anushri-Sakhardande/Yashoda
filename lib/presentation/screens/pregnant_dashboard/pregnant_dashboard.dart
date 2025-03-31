import 'package:flutter/material.dart';
import 'package:yashoda/presentation/screens/appointment/search_admin.dart';
import '../../widgets/custom_app_bar.dart';

class PregnantDashboard extends StatelessWidget {
  final dynamic userProfile;

  PregnantDashboard({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Pregnant Mother Dashboard", uid: userProfile["uid"], userProfile: userProfile),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Welcome, ${userProfile["name"]}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Pregnancy Weeks: ${userProfile["pregnancyWeeks"]}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text("View Doctor Visits"),
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

          ],
        ),
      ),
    );
  }
}
