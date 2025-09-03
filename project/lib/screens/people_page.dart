import 'package:flutter/material.dart';
import 'package:happiness_hub/models/person.dart';
import 'package:happiness_hub/services/firestore_service.dart';
import 'package:happiness_hub/screens/add_edit_person_page.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

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

          // Calculate stats from the live data
          final closeBonds = people.where((p) => p.connectionStrength >= 4).length;

          return ListView(
            padding: const EdgeInsets.all(12.0),
            children: [
              // Stats Cards
              _buildStatsRow(context, people.length, closeBonds),
              const SizedBox(height: 20),
              // People List
              ...people.map((person) => _buildPersonCard(context, person, firestoreService)).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the screen to add a new person
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditPersonPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Builds the row of statistics cards at the top of the page
  Widget _buildStatsRow(BuildContext context, int totalContacts, int closeBonds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(context, 'Contacts', totalContacts.toString(), Icons.people_outline),
        _buildStatCard(context, 'Close Bonds', closeBonds.toString(), Icons.favorite_border),
        // Placeholder for a future feature
        _buildStatCard(context, 'Check-in', 'Soon', Icons.notifications_none),
      ],
    );
  }

  // Builds a single statistic card
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

  // Builds the main card for displaying a single person's information
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
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
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
                // Star rating for connection strength
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < person.connectionStrength ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            if (person.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                person.notes,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Divider(height: 24),
            // Action buttons for the card
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigate to the edit page, passing the current person's data
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddEditPersonPage(person: person),
                    ));
                  },
                  child: const Text('Edit / View'),
                ),
                const SizedBox(width: 8),
                 IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                  onPressed: () {
                    // Show a confirmation dialog before deleting
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: const Text('Are you sure?'),
                              content: Text('Do you want to remove ${person.name} from your list?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('No')),
                                TextButton(
                                    onPressed: () {
                                      service.deletePerson(person.id);
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('Yes')),
                              ],
                            ));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

