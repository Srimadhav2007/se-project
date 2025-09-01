import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});
  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}
class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'ai', 'text': 'Hello! I\'m your wellness AI assistant. How can I support you today?'},
  ];


  void _sendMessage() async {
  if (_controller.text.isEmpty) return;
  setState(() {
    _messages.add({'sender': 'user', 'text': _controller.text});
  });

  try {
    final Uri url = Uri.parse('https://ai-for-project.onrender.com/predict');
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final String body = 'Query=${Uri.encodeComponent(_controller.text)}';
    final http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    _controller.clear();

    if (response.statusCode == 200) {
      final aiResponse = response.body;
      setState(() {
        _messages.add({'sender': 'ai', 'text': aiResponse});
      });
    } else {
      setState(() {
        _messages.add({'sender': 'ai', 'text': 'Error: Failed to get a response from the server.'});
      });
    }
  } catch (e) {
    setState(() {
      _messages.add({'sender': 'ai', 'text': 'Error: Could not connect to the server. Is it running? ${e.toString()}'});
      _controller.clear();
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).primaryColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(message['text']!, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Ask for advice...'),
                     onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
