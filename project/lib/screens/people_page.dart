import 'package:flutter/material.dart';
import 'package:happiness_hub/models/person.dart';
import 'package:happiness_hub/services/ai_service.dart';
import 'package:happiness_hub/services/firestore_service.dart';
import 'package:happiness_hub/screens/add_edit_person_page.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatelessWidget {
  final VoidCallback navigateToAIPage;
  const PeoplePage({super.key, required this.navigateToAIPage});

  
  void _showAIPromptDialog(BuildContext context, Person person) {
    final aiService = Provider.of<AIService>(context, listen: false);
    final queryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ask AI about ${person.name}'),
          content: TextField(
            controller: queryController,
            decoration: const InputDecoration(
              hintText: 'e.g., How can I strengthen our bond?',
              labelText: 'Your Question',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (queryController.text.isNotEmpty) {
                  
                  final prompt = """
                  I need relationship advice about a person in my life.
                  Here are the details:
                  - Name: ${person.name}
                  - My Relationship with them: ${person.relationship}
                  - My personal notes about them: "${person.notes}"
                  - On a scale of 1-5, I rate our connection strength as: ${person.connectionStrength}

                  My specific question is: "${queryController.text}"

                  Please provide thoughtful and actionable advice in short.
                  """;

                  // Send the prompt using the AIService
                  AIService.isRelationQuery = true;
                  aiService.sendMessage(prompt);
                  AIService.isRelationQuery = false;

                  
                  Navigator.of(context).pop();
                  navigateToAIPage();
                }
              },
              child: const Text('Ask AI'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Relationships"),
      ),
      body: StreamBuilder<List<Person>>(
        stream: firestoreService.getPeople(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No one here yet.\nTap the "+" button to add someone!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final people = snapshot.data!;
          final closeBonds = people.where((p) => p.connectionStrength >= 4).length;

          return ListView(
            padding: const EdgeInsets.all(12.0),
            children: [
              _buildStatsRow(context, people.length, closeBonds),
              const SizedBox(height: 20),
              ...people.map((person) => _buildPersonCard(context, person, firestoreService)).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditPersonPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, int totalContacts, int closeBonds) {
     return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(context, 'Contacts', totalContacts.toString(), Icons.people_outline),
        _buildStatCard(context, 'Close Bonds', closeBonds.toString(), Icons.favorite_border),
        _buildStatCard(context, 'Check-in', 'Soon', Icons.notifications_none),
      ],
    );
  }

   Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  
  Widget _buildPersonCard(BuildContext context, Person person, FirestoreService service) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(person.relationship, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) => Icon(index < person.connectionStrength ? Icons.star : Icons.star_border, color: Colors.amber, size: 20)),
                ),
              ],
            ),
            if (person.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(person.notes, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // NEW "Ask AI" Button
                TextButton.icon(
                  onPressed: () => _showAIPromptDialog(context, person),
                  icon: Icon(Icons.psychology_alt, size: 20, color: Theme.of(context).colorScheme.secondary),
                  label: Text('Ask AI', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditPersonPage(person: person)));
                      },
                      child: const Text('Edit/View'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: Text('Do you want to remove ${person.name} from your list?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('No')),
                              TextButton(onPressed: () { service.deletePerson(person.id); Navigator.of(ctx).pop(); }, child: const Text('Yes')),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

