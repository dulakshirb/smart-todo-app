import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskStats extends StatelessWidget {
  const TaskStats({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;
    final pendingTasks = taskProvider.incompleteTasks.length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            context,
            'Total Tasks',
            totalTasks,
            Icons.task,
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            context,
            'Completed',
            completedTasks,
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            context,
            'Pending',
            pendingTasks,
            Icons.pending,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
