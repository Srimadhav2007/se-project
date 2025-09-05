import 'package:flutter/material.dart';
import 'package:happiness_hub/screens/home_page.dart';
import 'package:happiness_hub/screens/schedule_page.dart';
import 'package:happiness_hub/screens/people_page.dart';
import 'package:happiness_hub/screens/health_page.dart';
import 'package:happiness_hub/screens/ai_assistant_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // This function will be passed to the PeoplePage to allow it to change the tab.
  void _navigateToAIPage() {
    setState(() {
      _selectedIndex = 4; // Index of the AI page
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      HomePage(onNavigate: (index) => setState(() => _selectedIndex = index)),
      const SchedulePage(),
      PeoplePage(navigateToAIPage: _navigateToAIPage), // Pass the callback here
      const HealthPage(),
      const AIAssistantPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), activeIcon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'People'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'AI'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

