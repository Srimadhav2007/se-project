import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HealthReminder {
  final String id;
  final String title;
  final String description;
  final TimeOfDay time;
  final List<bool> daysOfWeek; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  final bool isActive;
  final String category; // 'water', 'medicine', 'exercise', 'meal', 'other'
  final DateTime createdAt;

  HealthReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.daysOfWeek,
    required this.isActive,
    required this.category,
    required this.createdAt,
  });

  // Factory constructor to create a HealthReminder from a Firestore document
  factory HealthReminder.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return HealthReminder(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      time: TimeOfDay(
        hour: data['hour'] ?? 0,
        minute: data['minute'] ?? 0,
      ),
      daysOfWeek: List<bool>.from(data['daysOfWeek'] ?? List.filled(7, false)),
      isActive: data['isActive'] ?? true,
      category: data['category'] ?? 'other',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Method to convert a HealthReminder object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'hour': time.hour,
      'minute': time.minute,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
    HealthReminder copyWith({
    String? id,
    String? title,
    String? description,
    TimeOfDay? time,
    List<bool>? daysOfWeek,
    bool? isActive,
    String? category,
    DateTime? createdAt,
  }) {
    return HealthReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
