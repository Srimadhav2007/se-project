import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happiness_hub/models/task.dart';

class FirestoreService {
  // Get an instance of the Firestore database
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of tasks
  // The UI will listen to this stream for real-time updates
  Stream<List<Task>> getTasks() {
    return _db.collection('tasks').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Add a new task
  Future<void> addTask(Task task) {
    return _db.collection('tasks').add(task.toFirestore());
  }

  // Update an existing task's 'completed' status
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) {
    return _db.collection('tasks').doc(taskId).update({'completed': isCompleted});
  }

  // Delete a task
  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }
}
