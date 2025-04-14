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
      backgroundColor: Color(0xFFF4B860),
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
            } else if (choice == "Change Role") {
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
    final currentRole = userProfile["role"];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Update Life Stage"),
          content: Text("Please choose the option that best reflects your current stage."),
          actions: [
            if (currentRole != "New Mother")
              TextButton(
                onPressed: () {
                  _confirmRoleChange("New Mother", context);
                },
                child: Text("I'm now a New Mother"),
              ),
            if (currentRole != "Miscarried")
              TextButton(
                onPressed: () {
                  _confirmRoleChange("Miscarried", context);
                },
                child: Text("I’ve experienced a pregnancy loss"),
              ),
            if (currentRole != "Pregnant")
              TextButton(
                onPressed: () {
                  _confirmRoleChange("Pregnant", context);
                },
                child: Text("I'm now Pregnant"),
              ),
          ],
        );
      },
    );
  }


  void _confirmRoleChange(String newRole, BuildContext context) {
    final TextEditingController weeksController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext confirmContext) {
        return AlertDialog(
          title: Text("Confirm Change"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                newRole == "Experienced Pregnancy Loss"
                    ? "We're here for you. Updating your stage will help us provide gentle and supportive features tailored to your journey. Would you like to proceed?"
                    : "Updating your profile will tailor the experience to your current life stage. Please confirm.",
              ),
              if (newRole == "Pregnant")
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextField(
                    controller: weeksController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Enter number of pregnancy weeks",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String? weeksText = weeksController.text.trim();
                if (newRole == "Pregnant" && (weeksText.isEmpty || int.tryParse(weeksText) == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid number of weeks.")),
                  );
                  return;
                }

                Navigator.pop(confirmContext);
                _updateRole(newRole, context, pregnancyWeeks: newRole == "Pregnant" ? int.parse(weeksText) : null);
              },
              child: Text("Yes, update"),
            ),
          ],
        );
      },
    );
  }



  void _updateRole(String newRole, BuildContext context, {int? pregnancyWeeks}) async {
    try {
      Map<String, dynamic> updateData = {"role": newRole};

      if (newRole == "New Mother") {
        updateData["babyMonths"] = 0;
        updateData.remove("pregnancyWeeks");
      } else if (newRole == "Pregnant") {
        updateData["pregnancyWeeks"] = pregnancyWeeks ?? 0;
        updateData.remove("babyMonths");
      } else if (newRole == "Experienced Pregnancy Loss") {
        updateData.remove("pregnancyWeeks");
        updateData.remove("babyMonths");
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newRole == "Experienced Pregnancy Loss"
                ? "We're sending you strength. Your profile has been updated with care."
                : "Profile updated to reflect your new journey as a $newRole.",
          ),
        ),
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
