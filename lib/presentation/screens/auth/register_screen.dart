import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController pregnancyWeeksController = TextEditingController();
  final TextEditingController babyMonthsController = TextEditingController();

  String role = "Pregnant"; // Default role
  String location = "Fetching...";
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    String loc = await LocationService().getUserLocation();
      setState(() {
        location = loc;
      });
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: Text("Register"),
      backgroundColor: Color(0xFFF4B860),),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Full Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),

            DropdownButton<String>(
              value: role,
              items: ["Pregnant", "New Mother", "Miscarried", "Health Administrator"].map((String value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (newRole) {
                setState(() {
                  role = newRole!;
                });
              },
            ),

            if (role == "Pregnant")
              TextField(controller: pregnancyWeeksController, decoration: InputDecoration(labelText: "Weeks Pregnant"), keyboardType: TextInputType.number),

            if (role == "New Mother")
              TextField(controller: babyMonthsController, decoration: InputDecoration(labelText: "Baby Months"), keyboardType: TextInputType.number),

            SizedBox(height: 10),
            Text("Location: $location"),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                var user = await authService.registerUser(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  name: nameController.text.trim(),
                  role: role,
                  extraData: {
                    "location": location,
                    "latitude": latitude,
                    "longitude": longitude,
                    if (role == "Pregnant") "pregnancyWeeks": int.tryParse(pregnancyWeeksController.text.trim()) ?? 0,
                    if (role == "New Mother") "babyMonths": int.tryParse(babyMonthsController.text.trim()) ?? 0,
                  }, context: context,
                );

                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
