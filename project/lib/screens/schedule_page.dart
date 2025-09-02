import 'package:flutter/material.dart';
import 'package:happiness_hub/models/task.dart';
import 'package:happiness_hub/services/auth_service.dart';
import 'package:happiness_hub/services/firestore_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // Method to show a dialog for adding a new task
  void _showTaskDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    String category = 'Personal'; // Default category

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: timeController,
                  decoration:
                      const InputDecoration(labelText: 'Time (e.g., 10:00 AM)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a time' : null,
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Personal', 'Work', 'Health', 'Wellness']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      category = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newTask = Task(
                    id: '', // Firestore generates the ID
                    title: titleController.text,
                    time: timeController.text,
                    category: category,
                    completed: false,
                  );
                  _firestoreService.addTask(newTask);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.currentUser == null) {
      return const Center(
        child: Text("Please log in to manage your schedule."),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No tasks found. Add one to get started!'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  _firestoreService.deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${task.title} deleted")),
                  );
                },
                background: Container(
                  color: Colors.red[400],
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Checkbox(
                      value: task.completed,
                      onChanged: (bool? value) {
                        _firestoreService.updateTaskCompletion(task.id, value!);
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.completed ? Colors.grey[600] : null,
                      ),
                    ),
                    subtitle: Text(task.time),
                    trailing: Chip(
                        label: Text(task.category),
                        backgroundColor: Colors.grey.shade200),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

