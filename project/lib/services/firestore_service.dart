import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_hub/models/person.dart';
import 'package:happiness_hub/models/task.dart';

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
}

