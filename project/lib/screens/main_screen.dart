import 'package:flutter/material.dart';
import 'package:happiness_hub/screens/ai_assistant_page.dart';
import 'package:happiness_hub/screens/health_page.dart';
import 'package:happiness_hub/screens/home_page.dart';
import 'package:happiness_hub/screens/people_page.dart';
import 'package:happiness_hub/screens/schedule_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 'home' is the default tab

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(onNavigate: (index) => _onItemTapped(index)),
      const SchedulePage(),
      const PeoplePage(),
      const HealthPage(),
      const AIAssistantPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_outlined, 'label': 'Home', 'active_icon': Icons.home},
      {'icon': Icons.schedule_outlined, 'label': 'Schedule', 'active_icon': Icons.schedule},
      {'icon': Icons.people_outline, 'label': 'People', 'active_icon': Icons.people},
      {'icon': Icons.favorite_border, 'label': 'Health', 'active_icon': Icons.favorite},
      {'icon': Icons.chat_bubble_outline, 'label': 'AI', 'active_icon': Icons.chat_bubble},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = _selectedIndex == index;
              return InkWell(
                onTap: () => _onItemTapped(index),
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? item['active_icon'] : item['icon'],
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
