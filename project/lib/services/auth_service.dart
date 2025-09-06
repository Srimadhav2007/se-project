import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_hub/models/user_profile.dart';
import 'package:happiness_hub/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // You can handle specific errors here if you want (e.g., wrong password)
      print('Sign in failed: ${e.message}');
      return null;
    }
  }

  // --- MODIFIED: Sign up with email, password, and create profile ---
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      // 1. Create the user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // 2. If creation is successful, create the profile document in Firestore
      if (userCredential.user != null) {
        UserProfile newUserProfile = UserProfile(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          // Other fields can be left as default or empty
        );
        // Use the FirestoreService to save the new profile
        await _firestoreService.setUserProfile(newUserProfile);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors like 'email-already-in-use'
      print('Sign up failed: ${e.message}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
}
}