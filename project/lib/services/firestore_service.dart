import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:happiness_hub/models/task.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Get the current user
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Helper method to get the user's tasks collection reference.
  // This is the core of the multi-user logic.
  CollectionReference<Map<String, dynamic>> _userTasksCollection() {
    final uid = _currentUser?.uid;
    if (uid == null) {
      // This is a safeguard. The UI should prevent this from being called
      // if the user is not logged in.
      throw Exception("User not logged in. Cannot access Firestore.");
    }
    // This creates the correct path: users -> {userId} -> tasks
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // Get a stream of tasks FOR THE CURRENT USER
  Stream<List<Task>> getTasks() {
    return _userTasksCollection().snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Add a new task FOR THE CURRENT USER
  Future<void> addTask(Task task) {
    // We pass the task object, which gets converted to a Map by the toFirestore method.
    return _userTasksCollection().add(task.toFirestore());
  }

  // Update a task's completion status FOR THE CURRENT USER
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) {
    return _userTasksCollection().doc(taskId).update({'completed': isCompleted});
  }

  // Delete a task FOR THE CURRENT USER
  Future<void> deleteTask(String taskId) {
    return _userTasksCollection().doc(taskId).delete();
  }
}

