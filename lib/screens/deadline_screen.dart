import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/task_model.dart';
import '../utils/deadline_reminder.dart';

class DeadlineScreen extends StatefulWidget {
  final int? userId;

  const DeadlineScreen({super.key, this.userId});

  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  final DBHelper _dbHelper = DBHelper();

  List<TaskModel> _tasks = [];
  TaskModel? _selectedTask;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _dbHelper.getAllTasks(userId: widget.userId);
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deadline Reminder"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<TaskModel>(
                    decoration: InputDecoration(
                      labelText: "Select Task",
                      prefixIcon: const Icon(
                        Icons.task_alt,
                        color: Colors.blueAccent,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: _selectedTask,
                    items: _tasks.map((task) {
                      return DropdownMenuItem(
                        value: task,
                        child: Text(task.title),
                      );
                    }).toList(),
                    onChanged: (task) {
                      setState(() {
                        _selectedTask = task;
                      });
                    },
                  ),
                ),
                if (_selectedTask != null) _buildDeadlineInfo(_selectedTask!),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "No tasks available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Add tasks first to track deadlines",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineInfo(TaskModel task) {
    Duration remaining = calculateRemainingTime(task.dueDate);
    String remainingText = formatRemainingTime(remaining);
    DateTime now = DateTime.now();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            task.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Due Date", task.dueDate),
          _buildInfoRow("Today", "${now.year}-${now.month}-${now.day}"),
          const SizedBox(height: 16),
          Text(
            remainingText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
