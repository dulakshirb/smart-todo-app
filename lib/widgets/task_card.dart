import 'package:dd_smart_todo_app/models/task_model.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/screens/task/task_detail_screen.dart';
import 'package:dd_smart_todo_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    // Get category details from CategoryProvider
    final category =
        Provider.of<CategoryProvider>(context).categories.firstWhere(
              (c) => c.id == task.categoryId,
              orElse: () => Constants.getUncategorizedCategory(task.userId),
            );

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
      },
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(task: task),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: category.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    Provider.of<TaskProvider>(context, listen: false)
                        .toggleTaskCompletion(task);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Task Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Row
                    Row(
                      children: [
                        Icon(
                          category.icon,
                          size: 14,
                          color: category.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: category.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                    ),

                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Priority and Due Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.priority.toUpperCase(),
                      style: TextStyle(
                        color: _getPriorityColor(task.priority),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDueDate(task.dueDate),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.dueTime,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatDueDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
