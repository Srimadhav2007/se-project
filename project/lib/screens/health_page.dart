import 'package:flutter/material.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health")),
      body: ListView(
        children: [
          _buildHealthCard(context, icon: Icons.self_improvement, title: 'Mindfulness Exercises', subtitle: 'Guided meditations', color: Colors.blue.shade300),
          _buildHealthCard(context, icon: Icons.medical_services_outlined, title: 'Symptom Checker', subtitle: 'Get preliminary information', color: Colors.red.shade300),
        ],
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(icon, size: 40, color: color),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
