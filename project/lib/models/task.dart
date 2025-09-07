import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final DateTime dateTime;
  final String category;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.category,
    required this.completed,
  });

  
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      category: data['category'] ?? 'Personal',
      completed: data['completed'] ?? false,
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'dateTime': Timestamp.fromDate(dateTime),
      'category': category,
      'completed': completed,
    };
  }
}

