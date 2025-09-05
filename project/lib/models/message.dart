import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  // Factory constructor to create a Message from Firestore document
  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Message to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}