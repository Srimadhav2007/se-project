import 'package:flutter/material.dart';
import 'package:happiness_hub/models/health_profile.dart';
import 'package:happiness_hub/models/health_reminder.dart';
import 'package:happiness_hub/models/fitness_tips.dart';
import 'package:happiness_hub/services/auth_service.dart';
import 'package:happiness_hub/services/health_firestore_service.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final HealthFirestoreService _healthService = HealthFirestoreService();
  final AuthService _authService = AuthService();
  
  String _selectedFitnessGoal = 'general_health';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Health & Wellness'),
        ),
        body: const Center(
          child: Text("Please log in to manage your health data."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Wellness'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Reminders'),
            Tab(text: 'Fitness Tips'),
            Tab(text: 'Conditions'),
          ],
        ),
      ),
      body: StreamBuilder<HealthProfile>(
        stream: _healthService.getHealthProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No health profile found.'));
          }

          final healthProfile = snapshot.data!;
          _selectedFitnessGoal = healthProfile.fitnessGoal;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProfileTab(healthProfile),
              _buildRemindersTab(),
              _buildFitnessTipsTab(),
              _buildConditionsTab(healthProfile),
            ],
          );
        },
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () => _showAddReminderDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHealthOverview(HealthProfile healthProfile) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 28),
                const SizedBox(width: 8),
                Text(
                  healthProfile.name?.isNotEmpty == true ? healthProfile.name! : 'Health Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showEditProfileDialog(context, healthProfile),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSimpleMetric('Weight', healthProfile.weight != null ? '${healthProfile.weight!.toStringAsFixed(1)} kg' : '--'),
                _buildSimpleMetric('Height', healthProfile.height != null ? '${healthProfile.height!.toStringAsFixed(0)} cm' : '--'),
                _buildSimpleMetric('BMI', healthProfile.bmi != null ? healthProfile.bmi!.toStringAsFixed(1) : '--'),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'BMI Category: ${healthProfile.bmiCategory ?? '--'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Date of Birth', healthProfile.dateOfBirth != null ? '${healthProfile.dateOfBirth!.toLocal()}'.split(' ')[0] : '--'),
            _buildInfoRow('Gender', healthProfile.gender ?? '--'),
            _buildInfoRow('Blood Group', healthProfile.bloodGroup ?? '--'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSimpleMetric(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileTab(HealthProfile healthProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthOverview(healthProfile),
          const SizedBox(height: 24),
          Text('Fitness Goal', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: healthProfile.fitnessGoal,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            items: const [
              DropdownMenuItem(value: 'general_health', child: Text('General Health')),
              DropdownMenuItem(value: 'weight_loss', child: Text('Weight Loss')),
              DropdownMenuItem(value: 'bodybuilding', child: Text('Bodybuilding')),
              DropdownMenuItem(value: 'endurance', child: Text('Endurance')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedFitnessGoal = value);
                final updatedProfile = healthProfile.copyWith(fitnessGoal: value, lastUpdated: DateTime.now());
                _healthService.saveHealthProfile(updatedProfile);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersTab() {
    return StreamBuilder<List<HealthReminder>>(
      stream: _healthService.getReminders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final reminders = snapshot.data ?? [];
        if (reminders.isEmpty) {
          return const Center(child: Text('No reminders set. Add one!'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return Card(
              child: ListTile(
                leading: Icon(_getCategoryIcon(reminder.category)),
                title: Text(reminder.title),
                subtitle: Text('${reminder.description}\n${_formatTime(reminder.time)}'),
                trailing: Switch(
                  value: reminder.isActive,
                  onChanged: (value) {
                    final updatedReminder = reminder.copyWith(isActive: value);
                    _healthService.updateReminder(updatedReminder);
                  },
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFitnessTipsTab() {
    List<FitnessTip> tips = [];
    switch (_selectedFitnessGoal) {
      case 'bodybuilding':
        tips = FitnessTipsData.getBodybuildingTips();
        break;
      case 'weight_loss':
        tips = FitnessTipsData.getWeightLossTips();
        break;
      case 'general_health':
        tips = FitnessTipsData.getGeneralHealthTips();
        break;
      case 'endurance':
        tips = FitnessTipsData.getEnduranceTips();
        break;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return Card(
          child: ExpansionTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(tip.title),
            children: [
              Padding(
                padding: const EdgeInsets.all(16).copyWith(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.description, style: const TextStyle(fontStyle: FontStyle.italic)),
                    const Divider(height: 20),
                    const Text('Foods:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...tip.foods.map((food) => Text('• $food')),
                    const SizedBox(height: 8),
                    const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...tip.exercises.map((exercise) => Text('• $exercise')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionsTab(HealthProfile healthProfile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildEditableListSection(
            title: 'Health Conditions',
            items: healthProfile.healthConditions,
            icon: Icons.medical_services,
            iconColor: Colors.red,
            onAdd: () => _showAddConditionDialog(context, healthProfile),
            onDelete: (item) {
              final updatedItems = List<String>.from(healthProfile.healthConditions)..remove(item);
              final updatedProfile = healthProfile.copyWith(healthConditions: updatedItems, lastUpdated: DateTime.now());
              _healthService.saveHealthProfile(updatedProfile);
            },
          ),
          const SizedBox(height: 24),
          _buildEditableListSection(
            title: 'Remedies',
            items: healthProfile.remedies,
            icon: Icons.healing,
            iconColor: Colors.green,
            onAdd: () => _showAddRemedyDialog(context, healthProfile),
            onDelete: (item) {
              final updatedItems = List<String>.from(healthProfile.remedies)..remove(item);
              final updatedProfile = healthProfile.copyWith(remedies: updatedItems, lastUpdated: DateTime.now());
              _healthService.saveHealthProfile(updatedProfile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditableListSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onAdd,
    required ValueChanged<String> onDelete,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isNotEmpty
                ? ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(icon, color: iconColor),
                          title: Text(item),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => onDelete(item),
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: Text('No $title recorded')),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, HealthProfile currentProfile) {
    final nameController = TextEditingController(text: currentProfile.name);
    final weightController = TextEditingController(text: currentProfile.weight?.toString());
    final heightController = TextEditingController(text: currentProfile.height?.toString());
    DateTime? selectedDob = currentProfile.dateOfBirth;
    String? selectedGender = currentProfile.gender;
    String? selectedBloodGroup = currentProfile.bloodGroup;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Health Profile'),
        content: SingleChildScrollView(
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
                TextField(controller: heightController, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number),
                ListTile(
                  title: const Text('Date of Birth'),
                  subtitle: Text(selectedDob != null ? '${selectedDob!.toLocal()}'.split(' ')[0] : 'Not set'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDob ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => selectedDob = picked);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (value) => setState(() => selectedGender = value),
                ),
                DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(labelText: 'Blood Group'),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                  onChanged: (value) => setState(() => selectedBloodGroup = value),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final updatedProfile = currentProfile.copyWith(
                name: nameController.text.trim(),
                weight: double.tryParse(weightController.text),
                height: double.tryParse(heightController.text),
                dateOfBirth: selectedDob,
                gender: selectedGender,
                bloodGroup: selectedBloodGroup,
                lastUpdated: DateTime.now(),
              );
              _healthService.saveHealthProfile(updatedProfile);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddConditionDialog(BuildContext context, HealthProfile currentProfile) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Condition'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Condition', hintText: 'e.g., Asthma')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final updatedItems = List<String>.from(currentProfile.healthConditions)..add(controller.text.trim());
                final updatedProfile = currentProfile.copyWith(healthConditions: updatedItems, lastUpdated: DateTime.now());
                _healthService.saveHealthProfile(updatedProfile);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddRemedyDialog(BuildContext context, HealthProfile currentProfile) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Remedy'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Remedy', hintText: 'e.g., Inhaler')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final updatedItems = List<String>.from(currentProfile.remedies)..add(controller.text.trim());
                final updatedProfile = currentProfile.copyWith(remedies: updatedItems, lastUpdated: DateTime.now());
                _healthService.saveHealthProfile(updatedProfile);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedCategory = 'medicine';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('Add Health Reminder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(_formatTime(selectedTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: selectedTime);
                    if (time != null) setStateDialog(() => selectedTime = time);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['medicine', 'water', 'exercise', 'meal', 'other']
                      .map((label) => DropdownMenuItem(value: label, child: Text(label.capitalize())))
                      .toList(),
                  onChanged: (value) => setStateDialog(() => selectedCategory = value!),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    final newReminder = HealthReminder(
                      id: '', // Firestore generates ID
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      time: selectedTime,
                      daysOfWeek: List.filled(7, true), // Default to all days
                      isActive: true,
                      category: selectedCategory,
                      createdAt: DateTime.now(),
                    );
                    _healthService.addReminder(newReminder);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'water': return Icons.water_drop;
      case 'medicine': return Icons.medication;
      case 'exercise': return Icons.fitness_center;
      case 'meal': return Icons.restaurant;
      default: return Icons.notifications;
    }
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}