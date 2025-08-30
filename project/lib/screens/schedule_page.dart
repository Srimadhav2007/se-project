import 'package:flutter/material.dart';
import 'package:happiness_hub/models/task.dart';
import 'package:happiness_hub/services/firestore_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Instantiate our service
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule")),
      // Use a StreamBuilder to listen for real-time data
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.getTasks(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Handle error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Handle no data state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found. Add one!'));
          }

          // If we have data, display it
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                child: ListTile(
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (bool? value) {
                      // Call the service to update the task in Firestore
                      _firestoreService.updateTaskCompletion(task.id, value!);
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                      color: task.completed ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(task.time),
                  trailing: Chip(label: Text(task.category), backgroundColor: Colors.grey.shade200),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // USER_CODE: Here you would open a dialog or new screen to add a task.
          // For now, we'll add a sample task directly.
          final sampleTask = Task(
            id: '', // Firestore will generate the ID
            title: 'Test Task from App',
            time: '3:00 PM',
            category: 'Work',
            completed: false,
          );
          _firestoreService.addTask(sampleTask);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}