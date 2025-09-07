import 'package:flutter/material.dart';
import 'package:happiness_hub/models/task.dart';
import 'package:happiness_hub/services/auth_service.dart';
import 'package:happiness_hub/services/firestore_service.dart';
import 'package:happiness_hub/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Task>> _events;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
  }

 
  Map<DateTime, List<Task>> _groupTasksByDay(List<Task> tasks) {
    Map<DateTime, List<Task>> events = {};
    for (var task in tasks) {
      DateTime date =
          DateTime(task.dateTime.year, task.dateTime.month, task.dateTime.day);
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(task);
    }
    return events;
  }

 
  List<Task> _getEventsForDay(DateTime day) {
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  
  void _showAddTaskDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    String category = 'Personal';
    DateTime? selectedDate = _selectedDay;
    TimeOfDay? selectedTime = TimeOfDay.fromDateTime(_selectedDay);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Event'),
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
                    const SizedBox(height: 16),
                    // Date and Time Pickers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${DateFormat.yMd().format(selectedDate!)}'),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time: ${selectedTime!.format(context)}'),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setDialogState(() {
                                selectedTime = pickedTime;
                              });
                            }
                          },
                        ),
                      ],
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
                        if (value != null) category = value;
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
                    
                    if (formKey.currentState!.validate() &&
                        selectedDate != null &&
                        selectedTime != null) {
                      final finalDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );

                      final newTask = Task(
                        id: '', 
                        title: titleController.text,
                        dateTime: finalDateTime,
                        category: category,
                        completed: false,
                      );
                      _firestoreService.addTask(newTask).then((_) {
                        
                        _notificationService.scheduleNotification(newTask);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save Event'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.currentUser == null) {
      return const Center(child: Text("Please log in to see your schedule."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _authService.signOut(),
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
          if (!snapshot.hasData) {
            return const Center(child: Text('No events found.'));
          }

          final tasks = snapshot.data!;
          _events = _groupTasksByDay(tasks);
          final selectedDayEvents = _getEventsForDay(_selectedDay);

          return Column(
            children: [
              _buildCalendar(),
              const SizedBox(height: 8.0),
              Expanded(
                child: _buildEventList(selectedDayEvents),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: _getEventsForDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildEventList(List<Task> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          "No events for this day.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final task = events[index];
        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            _firestoreService.deleteTask(task.id);
            _notificationService.cancelNotification(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${task.title} deleted")),
            );
          },
          background: Container(
            color: Colors.red[400],
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: task.dateTime.isBefore(DateTime.now())?Checkbox(
                value: task.completed,
                onChanged: (bool? value) {
                  _firestoreService.updateTaskCompletion(task.id, value!);
                },
              ): Icon(
                task.category == 'Work' ? Icons.work : Icons.home,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(DateFormat.jm().format(task.dateTime)),
              trailing: Chip(
                label: Text(task.category),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
        );
      },
    );
  }
}

