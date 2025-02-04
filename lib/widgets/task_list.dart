import 'package:dd_smart_todo_app/models/task_model.dart';
import 'package:dd_smart_todo_app/widgets/task_card.dart';
import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  final List<TaskModel> tasks;

  const TaskList({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a task to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => TaskCard(task: tasks[index]),
    );
  }
}
