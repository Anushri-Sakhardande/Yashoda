import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import 'register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_dashboard/admin_dashboard.dart';
import '../mother_dashboard/mother_dashboard.dart';
import '../pregnant_dashboard/pregnant_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),

            if (errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(errorMessage, style: TextStyle(color: Colors.red)),
              ),

            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  errorMessage = "";
                });

                var user = await authService.loginUser(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );

                if (user != null) {
                  try {
                    // Fetch role from Firestore
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

                    if (userDoc.exists) {
                      String role = userDoc.get("role");
                      print("User Role: $role"); // Debugging

                      Widget dashboard;
                      if (role == "Pregnant") {
                        dashboard = PregnantDashboard();
                      } else if (role == "New Mother") {
                        dashboard = MotherDashboard();
                      } else if (role == "Health Administrator") {
                        dashboard = AdminDashboard();
                      } else {
                        setState(() => errorMessage = "Unknown role. Please contact support.");
                        return;
                      }

                      // Navigate to dashboard
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => dashboard),
                      );
                    } else {
                      setState(() => errorMessage = "User data not found. Try registering again.");
                    }
                  } catch (e) {
                    setState(() => errorMessage = "Error retrieving user data: $e");
                  }
                } else {
                  setState(() => errorMessage = "Invalid email or password.");
                }

                setState(() => isLoading = false);
              },
              child: Text("Login"),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
