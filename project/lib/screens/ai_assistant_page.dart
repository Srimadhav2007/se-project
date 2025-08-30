import 'package:flutter/material.dart';

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

  void _sendMessage() {
     if (_controller.text.isEmpty) return;
      setState(() {
      _messages.add({'sender': 'user', 'text': _controller.text});
      // USER_CODE: This is where you will call the Gemini API
      // For now, we simulate a response
      const aiResponse = "That's a great question! Improving work-life balance often starts with setting clear boundaries and prioritizing self-care.";
      _messages.add({'sender': 'ai', 'text': aiResponse});
    });
    _controller.clear();
    // Scroll to the bottom
    // You might need a ScrollController for this to work perfectly
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
