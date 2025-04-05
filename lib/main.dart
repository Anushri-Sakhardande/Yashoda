import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yashoda/presentation/screens/pregnant_dashboard/pregnant_dashboard.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/admin_dashboard/admin_dashboard.dart';
import 'presentation/screens/mother_dashboard/mother_dashboard.dart';
import 'presentation/screens/miscarried_dashboard/miscarried_dashboard.dart';
import 'package:timezone/data/latest_all.dart' as tz;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show initial loading screen while checking authentication
        if (snapshot.connectionState == ConnectionState.waiting) {
          return InitialLoadingScreen();
        }

        // If no user is logged in, show login screen
        if (!snapshot.hasData || snapshot.data == null) {
          return LoginScreen();
        }

        // Fetch user role from Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return InitialLoadingScreen();
            }

            // If user data is missing, return to login
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return LoginScreen();
            }

            // Get user role
            var userData = userSnapshot.data!;
            String role = userData["role"];

            // Define role-based dashboard mapping
            Map<String, Widget Function()> roleDashboards = {
              "New Mother": () => MotherDashboard(userProfile: userData),
              "Pregnant": () => PregnantDashboard(userProfile: userData),
              "Miscarriage": () => MiscarriedDashboard(userProfile: userData),
              "Health Administrator": () => AdminDashboard(userProfile: userData),
            };

            // Return the correct dashboard or an error screen
            return roleDashboards[role] != null
                ? roleDashboards[role]!()
                : ErrorScreen();
          },
        );
      },
    );
  }
}

// Loading screen while fetching user data
class InitialLoadingScreen extends StatelessWidget {
  const InitialLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// Error screen if an unknown role is encountered
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Unknown role. Please contact support.")),
    );
  }
}
