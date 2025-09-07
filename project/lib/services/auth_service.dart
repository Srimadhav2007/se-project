import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_hub/models/user_profile.dart';
import 'package:happiness_hub/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  
  User? get currentUser => _auth.currentUser;

  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      
      print('Sign in failed: ${e.message}');
      return null;
    }
  }

  
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      
      if (userCredential.user != null) {
        UserProfile newUserProfile = UserProfile(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          
        );
        
        await _firestoreService.setUserProfile(newUserProfile);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      
      print('Sign up failed: ${e.message}');
      return null;
    }
  }

  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}