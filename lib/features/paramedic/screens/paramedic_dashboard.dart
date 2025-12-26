import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import 'tabs/home_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/profile_tab.dart';

class ParamedicDashboardScreen extends StatefulWidget {
  const ParamedicDashboardScreen({super.key});

  @override
  State<ParamedicDashboardScreen> createState() =>
      _ParamedicDashboardScreenState();
}

class _ParamedicDashboardScreenState extends State<ParamedicDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ParamedicHomeTab(),
    ParamedicHistoryTab(),
    ParamedicProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.black,
          selectedItemColor: AppTheme.primaryAlert,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency_outlined),
              activeIcon: Icon(Icons.emergency),
              label: 'Action',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
