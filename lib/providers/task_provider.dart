import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final ApiService _api = ApiService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  int? _userId;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  List<TaskModel> get favoriteTasks =>
      _tasks.where((t) => t.isFavorite).toList();
  bool get isLoading => _isLoading;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  void init(int userId) {
    _userId = userId;
    loadTasks();
  }

  Future<void> loadTasks() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    // Load from local DB first so the UI is instant
    _tasks = await _db.getAllTasks(userId: _userId);
    _isLoading = false;
    notifyListeners();

    // Then fetch from server and sync any missing tasks into local DB
    final serverTasks = await _api.fetchTasks(_userId!);
    if (serverTasks.isNotEmpty) {
      final localIds = _tasks.map((t) => t.id).toSet();
      bool changed = false;
      for (final serverTask in serverTasks) {
        if (!localIds.contains(serverTask.id)) {
          await _db.insertTask(serverTask);
          changed = true;
        }
      }
      if (changed) {
        _tasks = await _db.getAllTasks(userId: _userId);
        notifyListeners();
      }
    }
  }

  Future<void> addTask(TaskModel task) async {
    task.userId = _userId;
    final id = await _db.insertTask(task);
    final saved = task.copyWith(id: id);
    _tasks.add(saved);
    notifyListeners();
    _api.createTask(saved);
  }

  Future<void> updateTask(TaskModel task) async {
    await _db.updateTask(task);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    notifyListeners();
    _api.updateTask(task);
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _api.deleteTask(id);
  }

  Future<void> toggleCompletion(TaskModel task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _db.updateTask(updated);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = updated;
    notifyListeners();
    _api.updateTask(updated);
  }

  Future<void> toggleFavorite(TaskModel task) async {
    final updated = task.copyWith(isFavorite: !task.isFavorite);
    await _db.updateTask(updated);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = updated;
    notifyListeners();
  }
}
