import 'package:flutter/material.dart';
import '../screens/task_screen.dart';
import '../screens/deadline_screen.dart';
import '../screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int? userId;

  const MainScreen({super.key, this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      TaskScreen(userId: widget.userId!),
      DeadlineScreen(userId: widget.userId!),
      ProfileScreen(userId: widget.userId!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Deadline"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
