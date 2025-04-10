import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/health_status/health_status_update.dart';

class HealthStatusBanner extends StatelessWidget {
  final String userId;

  const HealthStatusBanner({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("healthStatusEntries")
          .orderBy("lastUpdated", descending: true)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink(); // Avoid loading spinners for banners
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox.shrink(); // No entries yet
        }

        var latestEntry = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        DateTime lastUpdated = (latestEntry["lastUpdated"] as Timestamp).toDate();
        DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

        if (lastUpdated.isAfter(sevenDaysAgo)) {
          return SizedBox.shrink();  // No need to show banner
        }

        return Container(
          color: Colors.redAccent,
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Time to update your health status!",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HealthStatusScreen(userId: userId),
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
