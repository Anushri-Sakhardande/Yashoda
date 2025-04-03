import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/location_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;
  final dynamic userData;

  EditProfileScreen({required this.uid, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController locationController;
  late TextEditingController pregnancyWeeksController;
  late TextEditingController babyMonthsController;
  String role = "";
  bool isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData["name"]);
    emailController = TextEditingController(text: widget.userData["email"]);
    locationController = TextEditingController(text: widget.userData["location"]);
    pregnancyWeeksController = TextEditingController(
      text: widget.userData["role"] == "Pregnant" ? widget.userData["pregnancyWeeks"].toString() : "",
    );
    babyMonthsController = TextEditingController(
      text: widget.userData["role"] == "New Mother" ? widget.userData["babyMonths"].toString() : "",
    );
    role = widget.userData["role"];
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    pregnancyWeeksController.dispose();
    babyMonthsController.dispose();
    super.dispose();
  }

  Future<void> _fetchNewLocation() async {
    setState(() => isFetchingLocation = true);

    String loc = await LocationService().getUserLocation();

      setState(() {
        locationController.text = loc;
      });

    setState(() => isFetchingLocation = false);
  }

  void _updateProfile() async {
    try {
      dynamic updatedData = {
        "name": nameController.text.trim(),
        "location": locationController.text.trim(),
      };

      if (role == "Pregnant") {
        updatedData["pregnancyWeeks"] = pregnancyWeeksController.text.trim();
      } else if (role == "New Mother") {
        updatedData["babyMonths"] = babyMonthsController.text.trim();
      }

      await FirebaseFirestore.instance.collection("users").doc(widget.uid).update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Full Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email"), enabled: false),

            TextField(controller: locationController, decoration: InputDecoration(labelText: "Location")),

            Row(
              children: [
                ElevatedButton(
                  onPressed: isFetchingLocation ? null : _fetchNewLocation,
                  child: isFetchingLocation ? CircularProgressIndicator() : Text("Update Location"),
                ),
              ],
            ),

            if (role == "Pregnant")
              TextField(
                controller: pregnancyWeeksController,
                decoration: InputDecoration(labelText: "Weeks Pregnant"),
                keyboardType: TextInputType.number,
              ),

            if (role == "New Mother")
              TextField(
                controller: babyMonthsController,
                decoration: InputDecoration(labelText: "Baby Months"),
                keyboardType: TextInputType.number,
              ),

            SizedBox(height: 20),
            ElevatedButton(onPressed: _updateProfile, child: Text("Save Changes")),
          ],
        ),
      ),
    );
  }
}
