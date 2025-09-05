import 'package:flutter/material.dart';
import 'package:happiness_hub/services/ai_service.dart';
import 'package:provider/provider.dart';
import 'package:happiness_hub/services/firestore_service.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<List<String>> _previousChats = [];
  bool _showPreviousChats = false;
  bool _loadingPreviousChats = false;

  void _sendMessage(AIService aiService) {
    if (_controller.text.trim().isEmpty) return;

    aiService.sendMessage(_controller.text.trim());
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchPreviousChats() async {
    setState(() {
      _loadingPreviousChats = true;
    });
    final chats = await FirestoreService().getPreviousChats();
    setState(() {
      _previousChats = chats;
      _showPreviousChats = true;
      _loadingPreviousChats = false;
    });
  }

  Widget _buildPreviousChats() {
    if (_loadingPreviousChats) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_previousChats.isEmpty) {
      return const Center(child: Text('No previous chats found.'));
    }
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _previousChats.length,
        itemBuilder: (context, sessionIndex) {
          final session = _previousChats[sessionIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (session.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Session ${sessionIndex + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
              ...session.map((msg) {
                final parts = msg.split('|');
                final message = parts[0];
                final sender = parts[1];
                final timeStr = parts[2];
                final dateTime = DateTime.tryParse(timeStr);
                final formattedTime = dateTime != null
                    ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}'
                    : '';
                final isUser = sender == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).primaryColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            message,
                            style: TextStyle(color: isUser ? Colors.white : Colors.black),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(
                            formattedTime,
                            style: TextStyle(
                              color: isUser ? Colors.white70 : Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Consumer<AIService>(
    builder: (context, aiService, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("AI Assistant"),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Show Previous Chats',
              onPressed: _fetchPreviousChats,
            ),
            if (_showPreviousChats)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Hide Previous Chats',
                onPressed: () {
                  setState(() {
                    _showPreviousChats = false;
                  });
                },
              ),
          ],
        ),
        body: Column(
          children: [
            if (_showPreviousChats) ...[
              _buildPreviousChats(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('Continue Chat'),
                  onPressed: () {
                    setState(() {
                      _showPreviousChats = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: aiService.messages.length,
                  itemBuilder: (context, index) {
                    final message = aiService.messages[index];
                    final isUser = message['sender'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isUser ? Theme.of(context).primaryColor : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          message['text']!,
                          style: TextStyle(color: isUser ? Colors.white : Colors.black),
                        ),
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
                        onSubmitted: (value) => _sendMessage(aiService),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendMessage(aiService),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
}