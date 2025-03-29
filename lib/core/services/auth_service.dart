import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  }) async {
    try {
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
          ...extraData,  // Additional data like location, pregnancy stage
        });
      }
      return user;
    } catch (e) {
      //print("Error: $e");
      return null;
    }
  }

  // Login User
  Future<User?> loginUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      //print("Login Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  //Fetch user profile
  Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      return await FirebaseFirestore.instance.collection("users").doc(uid).get();
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

}
