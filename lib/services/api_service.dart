import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class ApiService {
  // 10.0.2.2 maps to localhost on Android emulator
  static const String _base = 'http://10.0.2.2:3000/api';

  Future<void> createTask(TaskModel task) async {
    try {
      await http
          .post(
            Uri.parse('$_base/tasks'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(task.toMap()),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await http
          .put(
            Uri.parse('$_base/tasks/${task.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(task.toMap()),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> deleteTask(int id) async {
    try {
      await http
          .delete(Uri.parse('$_base/tasks/$id'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<List<TaskModel>> fetchTasks(int userId) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/tasks?userId=$userId'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data
            .map((m) => TaskModel.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
