import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_hub/models/health_profile.dart';
import 'package:happiness_hub/models/health_reminder.dart';

class HealthFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String _getUid() {
    final uid = _currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in. Cannot access health data.");
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _getProfileDocRef() {
    return _db.collection('users').doc(_getUid()).collection('health_data').doc('profile');
  }

  CollectionReference<Map<String, dynamic>> _getRemindersCollectionRef() {
    return _db.collection('users').doc(_getUid()).collection('health_reminders');
  }

  Stream<HealthProfile> getHealthProfile() {
    return _getProfileDocRef().snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return HealthProfile.fromFirestore(snapshot);
      } else {
        return HealthProfile(id: 'profile');
      }
    });
  }

  Future<void> saveHealthProfile(HealthProfile profile) {
    return _getProfileDocRef().set(profile.toFirestore());
  }

  Stream<List<HealthReminder>> getReminders() {
    return _getRemindersCollectionRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthReminder.fromFirestore(doc))
            .toList());
  }

  Future<void> addReminder(HealthReminder reminder) {
    return _getRemindersCollectionRef().add(reminder.toFirestore());
  }

  Future<void> updateReminder(HealthReminder reminder) {
    return _getRemindersCollectionRef().doc(reminder.id).update(reminder.toFirestore());
  }

  Future<void> deleteReminder(String reminderId) {
    return _getRemindersCollectionRef().doc(reminderId).delete();
  }
}