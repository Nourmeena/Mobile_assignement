import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const Map<String, Color> _priorityColors = {
    'High': Color(0xFFE53935),
    'Medium': Color(0xFFFB8C00),
    'Low': Color(0xFF43A047),
  };

  static const Map<String, IconData> _priorityIcons = {
    'High': Icons.arrow_upward_rounded,
    'Medium': Icons.remove_rounded,
    'Low': Icons.arrow_downward_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<TaskProvider>().favoriteTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Favorite Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.amber[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
          ),
        ],
      ),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: favorites.length,
              itemBuilder: (ctx, i) => _buildCard(ctx, favorites[i]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border_rounded, size: 90, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No favorite tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the star icon on any task to add it here.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, TaskModel task) {
    final provider = context.read<TaskProvider>();
    final priorityColor = _priorityColors[task.priority] ?? Colors.blueAccent;
    final priorityIcon = _priorityIcons[task.priority] ?? Icons.remove;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.grey[300] : priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: task.isCompleted
                                  ? Colors.grey[400]
                                  : Colors.grey[850],
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (task.description != null &&
                              task.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.dueDate,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      priorityIcon,
                                      size: 11,
                                      color: priorityColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      task.priority,
                                      style: TextStyle(
                                        color: priorityColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: task.isCompleted
                                      ? Colors.green.withValues(alpha: 0.12)
                                      : Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  task.isCompleted ? 'Done' : 'Pending',
                                  style: TextStyle(
                                    color: task.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                      tooltip: 'Remove from favorites',
                      onPressed: () => provider.toggleFavorite(task),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
