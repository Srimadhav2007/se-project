import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For json decoding if the API returns JSON
import 'package:happiness_hub/models/message.dart';
import 'package:happiness_hub/services/firestore_service.dart' as firestore;


class AIService with ChangeNotifier {
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text':
          'Hello! Ask me for relationship advice or anything else you need help with.'
    },
  ];
  static bool isRelationQuery = false;
  
  List<Map<String, String>> get messages => _messages;

  
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.isEmpty) return;

   
    _messages.add({'sender': 'user', 'text': isRelationQuery ? 'Asking about a relationship...' : userMessage});
    
    notifyListeners();

    try {
      
      final Uri url = Uri.parse('https://ai-for-project.onrender.com/predict');
      final Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final String body = 'Query=${Uri.encodeComponent(userMessage)}';

      Message query = Message(
        id: DateTime.now().toString(),
        text: userMessage,
        senderId: 'user',
        timestamp: DateTime.now(),
      );
      firestore.FirestoreService().addMessage(query);

      final http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      String aiResponse;
      if (response.statusCode == 200) {
        // Assuming the response body is the plain text string.
        aiResponse = response.body;
        _messages.add({'sender': 'ai', 'text': aiResponse});
        Message answer = Message(
          id: DateTime.now().toString(),
          text: aiResponse,
          senderId: 'ai',
          timestamp: DateTime.now(),
        );
        firestore.FirestoreService().addMessage(answer);

      } else {
        aiResponse = 'Error: Failed to get a response from the server.';
      }
      
    } catch (e) {
       _messages.add({
        'sender': 'ai',
        'text': 'Error: Could not connect to the server. ${e.toString()}'
      });
    }
    
    notifyListeners();
  }
}

