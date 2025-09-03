import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_hub/models/health_profile.dart';
import 'package:happiness_hub/models/health_reminder.dart';

class HealthFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // --- Helper Methods ---

  /// Throws an exception if the user is not logged in.
  String _getUid() {
    final uid = _currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in. Cannot access health data.");
    }
    return uid;
  }

  /// Reference to the user's single health profile document.
  /// Path: users/{userId}/health_data/profile
  DocumentReference<Map<String, dynamic>> _getProfileDocRef() {
    return _db.collection('users').doc(_getUid()).collection('health_data').doc('profile');
  }

  /// Reference to the user's collection of health reminders.
  /// Path: users/{userId}/health_reminders
  CollectionReference<Map<String, dynamic>> _getRemindersCollectionRef() {
    return _db.collection('users').doc(_getUid()).collection('health_reminders');
  }


  // --- Health Profile Methods ---

  /// Get a stream of the user's health profile.
  /// If it doesn't exist, it returns a default, empty profile.
  Stream<HealthProfile> getHealthProfile() {
    return _getProfileDocRef().snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return HealthProfile.fromFirestore(snapshot);
      } else {
        // Return a default profile that can be updated by the user.
        return HealthProfile(id: 'profile');
      }
    });
  }

  /// Add or update the user's health profile.
  Future<void> saveHealthProfile(HealthProfile profile) {
    return _getProfileDocRef().set(profile.toFirestore());
  }


  // --- Health Reminders Methods ---

  /// Get a stream of all health reminders for the current user.
  Stream<List<HealthReminder>> getReminders() {
    return _getRemindersCollectionRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthReminder.fromFirestore(doc))
            .toList());
  }

  /// Add a new health reminder to Firestore.
  Future<void> addReminder(HealthReminder reminder) {
    return _getRemindersCollectionRef().add(reminder.toFirestore());
  }

  /// Update an existing reminder in Firestore.
  Future<void> updateReminder(HealthReminder reminder) {
    return _getRemindersCollectionRef().doc(reminder.id).update(reminder.toFirestore());
  }

  /// Delete a reminder from Firestore.
  Future<void> deleteReminder(String reminderId) {
    return _getRemindersCollectionRef().doc(reminderId).delete();
  }
}