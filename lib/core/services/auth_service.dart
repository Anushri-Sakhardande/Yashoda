import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register User
  Future<User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
    required Map<String, dynamic> extraData,
    required BuildContext context,  // Pass context for SnackBar
  }) async {
    try {
      if (password.length < 6) {
        _showSnackBar(context, "Password must be at least 6 characters long.");
        return null;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _db.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "role": role,
          ...extraData,
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showSnackBar(context, "The password is too weak.");
      } else {
        _showSnackBar(context, "Registration failed: ${e.message}");
      }
      return null;
    } catch (e) {
      _showSnackBar(context, "An error occurred: $e");
      return null;
    }
  }

  // Login User
  Future<User?> loginUser({
    required String email,
    required String password,
    required BuildContext context,  // Pass context for SnackBar
  }) async {
    try {
      if (password.length < 6) {
        _showSnackBar(context, "Password must be at least 6 characters long.");
        return null;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackBar(context, "Incorrect password.");
      } else if (e.code == 'user-not-found') {
        _showSnackBar(context, "No user found with this email.");
      } else {
        _showSnackBar(context, "Login failed: ${e.message}");
      }
      return null;
    } catch (e) {
      _showSnackBar(context, "An error occurred: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Fetch user profile
  Future<DocumentSnapshot?> getUserProfile(String uid, BuildContext context) async {
    try {
      return await FirebaseFirestore.instance.collection("users").doc(uid).get();
    } catch (e) {
      _showSnackBar(context, "Error fetching user profile: $e");
      return null;
    }
  }

  // Helper function to show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
