import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String email;
  final String notes;
  final int connectionStrength; // 1 to 5 star rating
  final List<String> tags;

  Person({
    required this.id,
    required this.name,
    required this.relationship,
    this.phone = '',
    this.email = '',
    this.notes = '',
    this.connectionStrength = 3,
    this.tags = const [],
  });

  // Factory constructor to create a Person from a Firestore document
  factory Person.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Person(
      id: doc.id,
      name: data['name'] ?? '',
      relationship: data['relationship'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      notes: data['notes'] ?? '',
      connectionStrength: data['connectionStrength'] ?? 3,
      // Handle tags which are stored as a list in Firestore
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // Method to convert a Person object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'notes': notes,
      'connectionStrength': connectionStrength,
      'tags': tags,
    };
  }
}
