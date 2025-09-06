import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_hub/models/person.dart';
import 'package:happiness_hub/models/task.dart';
import 'package:happiness_hub/models/message.dart';
import 'package:happiness_hub/models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // --- Task Methods ---

  // Helper to get the user-specific tasks collection reference
  CollectionReference<Map<String, dynamic>> _userTasksCollection() {
    final uid = _currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in. Cannot access Firestore.");
    }
    // Path: users -> {userId} -> tasks
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // Get a stream of tasks for the current user
  Stream<List<Task>> getTasks() {
    return _userTasksCollection().snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Add a new task for the current user
  Future<void> addTask(Task task) {
    return _userTasksCollection().add(task.toFirestore());
  }

  // Update a task's completion status for the current user
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) {
    return _userTasksCollection().doc(taskId).update({'completed': isCompleted});
  }

  // Delete a task for the current user
  Future<void> deleteTask(String taskId) {
    return _userTasksCollection().doc(taskId).delete();
  }

  // --- Person Methods ---

  // Helper to get the user-specific people collection reference
  CollectionReference<Map<String, dynamic>> _userPeopleCollection() {
    final uid = _currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in. Cannot access Firestore.");
    }
    // Path: users -> {userId} -> people
    return _db.collection('users').doc(uid).collection('people');
  }

  // Get a stream of people for the current user
  Stream<List<Person>> getPeople() {
    return _userPeopleCollection().snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList());
  }

  // Add a new person for the current user
  Future<void> addPerson(Person person) {
    return _userPeopleCollection().add(person.toFirestore());
  }

  // Update an existing person for the current user
  Future<void> updatePerson(Person person) {
    return _userPeopleCollection().doc(person.id).update(person.toFirestore());
  }

  // Delete a person for the current user
  Future<void> deletePerson(String personId) {
    return _userPeopleCollection().doc(personId).delete();
  }

  CollectionReference<Map<String, dynamic>> _userChatCollection() {
    final uid = _currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in. Cannot access Firestore.");
    }
    return _db.collection('users').doc(uid).collection('chat');
  }
  
  Stream<List<Message>> getMessages() {
    return _userChatCollection().orderBy('timestamp', descending: false).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList(),
    );
  }

  Future<void> addMessage(Message message) {
    return _userChatCollection().add(message.toFirestore());
  }

  Future<List<List<String>>> getPreviousChats() async {
  final querySnapshot = await _userChatCollection()
      .orderBy('timestamp', descending: false)
      .get();

  List<List<String>> chats = [];
  DateTime? lastSessionTime;

  for (final doc in querySnapshot.docs) {
    final data = doc.data();
    final sender = data['senderId']?.toString() ?? '';
    final message = data['text']?.toString() ?? '';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

    // Assuming sessions are separated by a significant time gap (e.g., 30 minutes)
    if (lastSessionTime == null ||
        (timestamp != null &&
            timestamp.difference(lastSessionTime).inMinutes > 30)) {
      chats.add([]);
    }
    if (chats.isNotEmpty && timestamp != null) {
      chats.last.add('$message|$sender|${timestamp.toIso8601String()}');
      lastSessionTime = timestamp;
    }
  }

  // Remove last session if it's too recent (optional logic)
  if (chats.isNotEmpty && chats.last.isNotEmpty) {
    final lastMsg = chats.last.last.split('|');
    if (lastMsg.length == 3) {
      final lastMsgTime = DateTime.tryParse(lastMsg[2]);
      final now = DateTime.now();
      if (lastMsgTime != null &&
          now.difference(lastMsgTime).inMinutes < 30) {
        chats.removeLast();
      }
    }
  }

  return chats;
}
  Future<void> clearMessages() async {
    final batch = _db.batch();
    final messages = await _userChatCollection().get();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

 DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _db.collection('users').doc(uid);
  }

  // Create or update the user's profile document.
  // This is often called right after a user signs up.
  Future<void> setUserProfile(UserProfile userProfile) {
    return _userDoc(userProfile.uid).set(userProfile.toFirestore());
  }

  // Get a stream of the user's profile data.
  Stream<UserProfile> getUserProfile(String uid) {
    return _userDoc(uid)
        .snapshots()
        .map((doc) => UserProfile.fromFirestore(doc));
  }

  // Update specific fields in the user's profile.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _userDoc(uid).update(data);
  }
}
