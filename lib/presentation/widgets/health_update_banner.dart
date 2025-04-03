import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/health_status/health_status_update.dart';

class HealthStatusBanner extends StatelessWidget {
  final String userId;

  HealthStatusBanner({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("health_status").doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return SizedBox.shrink();

        var data = snapshot.data!;
        DateTime lastUpdated = (data["lastUpdated"] as Timestamp).toDate();
        DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

        if (lastUpdated.isAfter(sevenDaysAgo)) {
          return SizedBox.shrink();  // No need for a banner
        }

        return Container(
          color: Colors.redAccent,
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Time to update your health status!",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HealthStatusScreen(userId: userId),  // Navigate to Health Status Screen
                    ),
                  );
                },
                child: Text(
                  "Update Now",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
