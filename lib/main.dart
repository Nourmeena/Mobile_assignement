import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'database/db_helper.dart';
import 'providers/task_provider.dart';

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
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) {
          final userId =
              ModalRoute.of(context)!.settings.arguments as int?;
          return ChangeNotifierProvider(
            create: (_) => TaskProvider()..init(userId!),
            child: MainScreen(userId: userId),
          );
        },
      },
    );
  }
}
