import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final DateTime dateTime; // Changed from String 'time' to DateTime
  final String category;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.category,
    required this.completed,
  });

  // Factory constructor to create a Task from a Firestore document
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      // Convert Firestore Timestamp to DateTime
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      category: data['category'] ?? 'Personal',
      completed: data['completed'] ?? false,
    );
  }

  // Method to convert a Task object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      // Convert DateTime to Firestore Timestamp
      'dateTime': Timestamp.fromDate(dateTime),
      'category': category,
      'completed': completed,
    };
  }
}

