import 'package:flutter/material.dart';
import 'package:happiness_hub/models/task.dart';
import 'package:happiness_hub/services/auth_service.dart';
import 'package:happiness_hub/services/firestore_service.dart';
import 'package:happiness_hub/screens/profile_page.dart';
import 'dart:async';
import 'package:intl/intl.dart'; 
import 'package:happiness_hub/services/notification_service.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  final authService = AuthService();
  final firestoreService = FirestoreService();
  final NotificationService notificationService = NotificationService();

  final List<String> _animatedDialogues = [
    "Welcome to Wellness Hub",
    "Where happiness is in your hands",
    "Be a good person who cares about their people",
    "Have good progress with our active reminders",
    "Your daily dose of positivity awaits!"
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      setState(() {
        _currentPage = (_currentPage + 1) % _animatedDialogues.length;
      });
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Wellness Hub'),
        content: const SingleChildScrollView(
          child: Text(
            'Wellness Hub is your personal companion on the journey to a happier, more balanced life. Our mission is to provide you with the tools to manage your tasks, nurture your relationships, and care for your well-being, all in one place.\n\n'
            'We believe that small, consistent actions lead to profound changes. Let us help you organize your day, connect with loved ones, and find moments of mindfulness. Welcome to a better you.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wellness Hub"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              } else if (value == 'logout') {
                authService.signOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('My Profile'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: firestoreService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No events found.'));
          }

          final allTasks = snapshot.data ?? [];
          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final endOfToday = startOfToday.add(const Duration(days: 1));

          final todayTasks = allTasks
              .where((task) =>
                  task.dateTime.isAfter(startOfToday) &&
                  task.dateTime.isBefore(endOfToday))
              .toList();
          final completedToday =
              todayTasks.where((task) => task.completed).length;

          final upcomingReminders = allTasks
              .where((task) => !task.completed && task.dateTime.isAfter(now))
              .length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated text
                SizedBox(
                  height: screenHeight * 0.06,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _animatedDialogues.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Text(
                          _animatedDialogues[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatsCards(
                  context,
                  '$completedToday/${todayTasks.length}',
                  upcomingReminders.toString(),
                ),
                const SizedBox(height: 20),
                Text("Upcoming Reminders",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(child: _buildUpcomingReminders(allTasks)),
                const SizedBox(height: 16),
                _buildQuickActions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(
      BuildContext context, String tasksDone, String reminders) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [
                Icon(Icons.check_circle_outline,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Progress",
                        style: TextStyle(fontSize: 12)),
                    Text(tasksDone,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [
                Icon(Icons.notifications_active_outlined,
                    color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Reminders", style: TextStyle(fontSize: 12)),
                    Text(reminders,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              ]),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => widget.onNavigate(1),
                icon: const Icon(Icons.add_task),
                label: const Text("Add Task"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => widget.onNavigate(4),
                icon: const Icon(Icons.psychology_alt),
                label: const Text("Ask AI"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingReminders(List<Task> allTasks) {
    final upcomingTasks =
        allTasks.where((task) => task.dateTime.isAfter(DateTime.now())).toList();

    if (upcomingTasks.isEmpty) {
      return const Center(
        child: Text(
          "No upcoming-task reminders",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      itemCount: upcomingTasks.length,
      itemBuilder: (context, index) {
        final task = upcomingTasks[index];
        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            firestoreService.deleteTask(task.id);
            notificationService.cancelNotification(task.id);
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              leading: task.dateTime.isBefore(DateTime.now())
                  ? Checkbox(
                      value: task.completed,
                      onChanged: (bool? value) {
                        firestoreService.updateTaskCompletion(task.id, value!);
                      },
                    )
                  : Icon(
                      task.category == 'Work' ? Icons.work : Icons.home,
                      color: Theme.of(context).primaryColor,
                    ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration:
                      task.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                DateFormat('MMM d, yyyy • h:mm a').format(task.dateTime),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
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
