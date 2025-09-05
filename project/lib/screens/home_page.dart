import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Function(int) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // Dummy data similar to the TSX file
    const int tasksDone = 1;
    const int totalTasks = 4;
    const int reminders = 3;

    return ListView(
      children: [
        const SizedBox(height: 16),
        _buildHomeHeader(context),
        const SizedBox(height: 24),
        _buildStatsCards(context, tasksDone, totalTasks, reminders),
        const SizedBox(height: 24),
        _buildActiveReminders(context),
        const SizedBox(height: 24),
        _buildTodaysTasks(context),
        const SizedBox(height: 24),
        _buildQuickActions(context),
        const SizedBox(height: 24),
        _buildRecentConnections(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHomeHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good morning, Alex!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Let's make today amazing", style: TextStyle(color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.notifications_none_outlined), onPressed: () {}),
            IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
            IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          ],
        )
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, int tasksDone, int totalTasks, int reminders) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [
                Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tasks Done", style: TextStyle(fontSize: 12)),
                    Text("$tasksDone/$totalTasks", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              ]),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [
                Icon(Icons.notifications_active_outlined, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Reminders", style: TextStyle(fontSize: 12)),
                    Text("$reminders", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              ]),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildActiveReminders(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Active Reminders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildReminderTile(context, "Drink water", "Stay hydrated! Time for your water break.", Icons.local_drink_outlined, Colors.blue),
            _buildReminderTile(context, "Take a break", "You've been working for 2 hours.", Icons.self_improvement, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTile(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.close, size: 18)),
        ],
      ),
    );
  }

  Widget _buildTodaysTasks(BuildContext context) {
     // Matching tasks from page.tsx
    final List<Map<String, dynamic>> tasks = [
      {'title': 'Morning meditation', 'time': '7:00 AM', 'completed': true, 'category': 'wellness'},
      {'title': 'Team meeting', 'time': '10:00 AM', 'completed': false, 'category': 'work'},
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...tasks.map((task) => _buildTaskTile(context, task)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTaskTile(BuildContext context, Map<String, dynamic> task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
           Icon(
            task['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task['completed'] ? Theme.of(context).primaryColor : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task['completed'] ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                Text(task['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Chip(
            label: Text(task['category']),
            backgroundColor: task['category'] == 'wellness' ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.grey.shade200,
            labelStyle: TextStyle(fontSize: 10, color: task['category'] == 'wellness' ? Theme.of(context).primaryColor : Colors.black),
            padding: const EdgeInsets.all(0),
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _quickActionButton(context, "Add Task", Icons.add, () => onNavigate(1))),
                const SizedBox(width: 16),
                Expanded(child: _quickActionButton(context, "AI Assistant", Icons.chat, () => onNavigate(4))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildRecentConnections(BuildContext context) {
    final List<Map<String, String>> people = [
      {'name': 'Sarah Johnson', 'relationship': 'Best Friend', 'lastContact': '2 days ago'},
      {'name': 'Mike Chen', 'relationship': 'Colleague', 'lastContact': '1 week ago'},
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Connections", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
             ...people.map((person) => ListTile(
              leading: CircleAvatar(
                // Placeholder avatar
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(person['name']![0], style: const TextStyle(color: Colors.white)),
              ),
              title: Text(person['name']!),
              subtitle: Text("${person['relationship']} • ${person['lastContact']}"),
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }
}
