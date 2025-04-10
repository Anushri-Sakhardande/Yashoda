import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import 'register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_dashboard/admin_dashboard.dart';
import '../mother_dashboard/mother_dashboard.dart';
import '../pregnant_dashboard/pregnant_dashboard.dart';
import '../miscarried_dashboard/miscarried_dashboard.dart';

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_login.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Login Form
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.4 * 255).toInt()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.email, color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.4 * 255).toInt()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Error Message
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                SizedBox(height: 20),

                // Login Button
                isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha((0.4 * 255).toInt()),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                      errorMessage = "";
                    });

                    var user = await authService.loginUser(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      context: context,
                    );

                    if (user != null) {
                      try {
                        // Fetch role from Firestore
                        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
                        var userDocMap = userDoc.data() as Map<String, dynamic>?;

                        if (userDoc.exists) {
                          String role = userDoc.get("role");

                          Widget dashboard;
                          if (role == "Pregnant") {
                            dashboard = PregnantDashboard(userProfile: userDocMap);
                          } else if (role == "New Mother") {
                            dashboard = MotherDashboard(userProfile: userDocMap);
                          } else if (role == "Health Administrator") {
                            dashboard = AdminDashboard(userProfile: userDocMap);
                          } else if (role == "Miscarriage") {
                            dashboard = MiscarriedDashboard(userProfile: userDocMap);
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
                  child: Text("Login", style: TextStyle(fontSize: 16, color: Colors.black)),
                ),

                SizedBox(height: 10),

                // Register Navigation
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                  },
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
