import 'package:flutter/material.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  // USER_CODE: Replace this with data from Firebase Firestore
  final List<Map<String, String>> _people = const [
    {'name': 'Alex Johnson', 'relationship': 'Colleague', 'avatar': 'A'},
    {'name': 'Maria Garcia', 'relationship': 'Friend', 'avatar': 'M'},
    {'name': 'David Smith', 'relationship': 'Mentor', 'avatar': 'D'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Relationships")),
      body: ListView.builder(
        itemCount: _people.length,
        itemBuilder: (context, index) {
          final person = _people[index];
          return Card(
             margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(person['avatar']!, style: const TextStyle(color: Colors.white)),
              ),
              title: Text(person['name']!),
              subtitle: Text(person['relationship']!),
            ),
          );
        },
      ),
    );
  }
}
