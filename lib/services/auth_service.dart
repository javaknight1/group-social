import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auth change user stream
  Stream<User?> get user => _auth.authStateChanges();

  // Add this getter to access current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email & password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

// In auth_service.dart, update registerWithEmailAndPassword:
Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
  // First register with Firebase Auth
  final userCredential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  
  // Then create a corresponding document in Firestore
  await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
    'email': email,
    'displayName': "No Name",
    'photoUrl': null,
    'socialAccounts': [],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  
  return userCredential;
}

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}