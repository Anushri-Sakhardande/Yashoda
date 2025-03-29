import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/auth/login_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String uid;
  final dynamic userProfile;

  CustomAppBar({required this.title, required this.uid, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String choice) {
            if (choice == "Edit Profile") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(uid: uid, userData: userProfile),
                ),
              );
            } else if (choice == "Change Role" && userProfile["role"] == "Pregnant") {
              _showRoleChangeDialog(context);
            } else if (choice == "View Details") {
              _showUserDetailsDialog(context);
            } else if (choice == "Logout") {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(value: "Edit Profile", child: Text("Edit Profile")),
              if (userProfile["role"] == "Pregnant")
                PopupMenuItem(value: "Change Role", child: Text("Change Role")),
              PopupMenuItem(value: "View Details", child: Text("View Details")),
              PopupMenuItem(value: "Logout", child: Text("Logout")),
            ];
          },
        ),
      ],
    );
  }

  void _showRoleChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Change Role"),
          content: Text("Select your new role:"),
          actions: [
            TextButton(
              onPressed: () {
                _updateRole("New Mother", context);
              },
              child: Text("New Mother"),
            ),
            TextButton(
              onPressed: () {
                _updateRole("Miscarriage", context);
              },
              child: Text("Miscarriage"),
            ),
          ],
        );
      },
    );
  }

  void _updateRole(String newRole, BuildContext context) async {
    try {
      Map<String, dynamic> updateData = {"role": newRole};

      if (newRole == "New Mother") {
        updateData["babyMonths"] = 0; // Initialize baby months
        updateData.remove("pregnancyWeeks"); // Remove pregnancy weeks
      } else if (newRole == "Miscarriage") {
        updateData.remove("pregnancyWeeks"); // Remove pregnancy tracking
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).update(updateData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Role updated to $newRole")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating role: $e")),
      );
    }
  }


  void _showUserDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("User Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${userProfile["name"]}"),
              Text("Email: ${userProfile["email"]}"),
              Text("Role: ${userProfile["role"]}"),
              if (userProfile["role"] == "Pregnant")
                Text("Weeks Pregnant: ${userProfile["pregnancyWeeks"]}"),
              if (userProfile["role"] == "New Mother")
                Text("Baby Months: ${userProfile["babyMonths"]}"),
              Text("Location: ${userProfile["location"]}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
