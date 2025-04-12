import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Dashboards
import 'package:yashoda/presentation/screens/pregnant_dashboard/pregnant_dashboard.dart';
import 'package:yashoda/presentation/screens/admin_dashboard/admin_dashboard.dart';
import 'package:yashoda/presentation/screens/mother_dashboard/mother_dashboard.dart';
import 'package:yashoda/presentation/screens/miscarried_dashboard/miscarried_dashboard.dart';

// Auth screen
import 'presentation/screens/auth/login_screen.dart';

// ChatBot Button
import 'package:yashoda/presentation/widgets/ChatBotButton.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Make sure this is correct
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return InitialLoadingScreen();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return LoginScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return InitialLoadingScreen();
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return LoginScreen();
            }

            var userData = userSnapshot.data!;
            String role = userData["role"];

            // 🧠 Role-based dashboard mapping with Chatbot FAB
            Map<String, Widget Function()> roleDashboards = {
              "New Mother": () => Scaffold(
                body: MotherDashboard(userProfile: userData),
                floatingActionButton: ChatBotButton(),
              ),
              "Pregnant": () => Scaffold(
                body: PregnantDashboard(userProfile: userData),
                floatingActionButton: ChatBotButton(),
              ),
              "Miscarriage": () => Scaffold(
                body: MiscarriedDashboard(userProfile: userData),
                floatingActionButton: ChatBotButton(),
              ),
              "Health Administrator": () => Scaffold(
                body: AdminDashboard(userProfile: userData),
                floatingActionButton: ChatBotButton(),
              ),
            };

            return roleDashboards[role] != null
                ? roleDashboards[role]!()
                : ErrorScreen();
          },
        );
      },
    );
  }
}

class InitialLoadingScreen extends StatelessWidget {
  const InitialLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Unknown role. Please contact support.")),
    );
  }
}
