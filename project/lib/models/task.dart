import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String time;
  final String category;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.completed,
  });

  // Factory constructor to create a Task from a Firestore document
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      category: data['category'] ?? 'Personal',
      completed: data['completed'] ?? false,
    );
  }

  // Method to convert a Task object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'time': time,
      'category': category,
      'completed': completed,
    };
  }
}
