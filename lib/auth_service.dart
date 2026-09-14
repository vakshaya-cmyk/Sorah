import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // 1. Login Caregiver
  Future<User?> loginCaregiver(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // For the prototype, auto-register if the account doesn't exist
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          return userCredential.user;
        } catch (innerE) {
          print('Error creating user: $innerE');
        }
      }
      print('Login error: $e');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  // 2. Generate Pairing Code
  Future<String> generatePairingCode(String uid) async {
    final random = Random();
    // Generates a 6-digit code
    final code = (random.nextInt(900000) + 100000).toString();

    await _firestore.collection('pairing_codes').doc(code).set({
      'caregiver_uid': uid,
      'created_at': FieldValue.serverTimestamp(),
    });

    return code;
  }

  // 3. Link Primary Device (Murobbi)
  Future<String?> linkPrimaryDevice(String code) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('pairing_codes').doc(code).get();
      if (doc.exists) {
        return doc.get('caregiver_uid') as String?;
      }
      return null;
    } catch (e) {
      print('Error linking device: $e');
      return null;
    }
  }
}