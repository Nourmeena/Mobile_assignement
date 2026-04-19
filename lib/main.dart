import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/login_screen.dart';
import 'screens/task_screen.dart';
import 'screens/signup_screen.dart';
import 'database/db_helper.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }


  final dbHelper = DBHelper();
  await dbHelper.db;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task Manager',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
      
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final userId = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) => TaskScreen(userId: userId),
          );
        }
        return null;
      },
    );
  }
}
