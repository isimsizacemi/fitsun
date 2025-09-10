import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Auth methods
  static Future<UserCredential?> signUp(String email, String password) async {
    try {
      print('Attempting to sign up with email: $email');
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign up successful: ${result.user?.uid}');
      return result;
    } catch (e) {
      print('Sign up error: $e');
      print('Error type: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        print('Error code: ${e.code}');
        print('Error message: ${e.message}');
      }
      return null;
    }
  }

  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static User? get currentUser => auth.currentUser;

  // Firestore methods
  static Future<void> saveUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await firestore.collection('users').doc(userId).set(profileData);
    } catch (e) {
      print('Save profile error: $e');
    }
  }

  static Future<DocumentSnapshot?> getUserProfile(String userId) async {
    try {
      return await firestore.collection('users').doc(userId).get();
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      print('Update profile error: $e');
    }
  }
}
