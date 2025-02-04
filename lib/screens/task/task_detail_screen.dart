import 'package:dd_smart_todo_app/models/category_model.dart';
import 'package:dd_smart_todo_app/models/task_model.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/screens/task/task_form_screen.dart';
import 'package:dd_smart_todo_app/utils/constants.dart';
import 'package:dd_smart_todo_app/utils/date_utils.dart';
import 'package:dd_smart_todo_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel currentTask;

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
  }

  void _updateTask() {
    if (!mounted) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final updatedTask = taskProvider.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    setState(() {
      currentTask = updatedTask;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;
    final category = categories.firstWhere(
      (c) => c.id == currentTask.categoryId,
      orElse: () => Constants.getUncategorizedCategory(currentTask.userId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTask.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskFormScreen(task: currentTask),
                ),
              );

              if (result == true && mounted) {
                _updateTask();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(context),
          const SizedBox(height: 24),
          _buildDetailsSection(context, category),
          const SizedBox(height: 24),
          if (currentTask.description.isNotEmpty) ...[
            _buildDescriptionSection(),
            const SizedBox(height: 24),
          ],
          _buildActionButtons(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final isOverdue = !currentTask.isCompleted &&
        DateTimeUtils.isOverdue(currentTask.dueDate, currentTask.dueTime);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentTask.isCompleted
              ? Colors.green
              : isOverdue
                  ? Colors.red
                  : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentTask.isCompleted ? 'Completed' : 'In Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: currentTask.isCompleted ? Colors.green : null,
                ),
              ),
              if (!currentTask.isCompleted && isOverdue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Overdue',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusItem(
                context,
                'Created',
                DateTimeUtils.getRelativeDate(currentTask.createdAt),
                Icons.calendar_today_outlined,
              ),
              const SizedBox(width: 24),
              _buildStatusItem(
                context,
                'Last Updated',
                DateTimeUtils.getRelativeDate(currentTask.updatedAt),
                Icons.update_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, CategoryModel category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                context,
                'Due Date',
                DateTimeUtils.formatDate(currentTask.dueDate),
                Icons.event_outlined,
              ),
              const Divider(height: 24),
              _buildDetailRow(
                context,
                'Due Time',
                currentTask.dueTime,
                Icons.access_time_outlined,
              ),
              const Divider(height: 24),
              _buildDetailRow(
                context,
                'Priority',
                currentTask.priority.toUpperCase(),
                Icons.flag_outlined,
                valueColor: _getPriorityColor(currentTask.priority),
              ),
              const Divider(height: 24),
              _buildCategoryRow(context, category),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryRow(BuildContext context, CategoryModel category) {
    final isDeletedCategory = category.id == 'deleted';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category.icon,
            size: 20,
            color: category.color,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: category.color,
                  ),
                ),
                if (isDeletedCategory) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Text(
            currentTask.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: currentTask.isCompleted
              ? 'Mark as Incomplete'
              : 'Mark as Complete',
          onPressed: () async {
            await Provider.of<TaskProvider>(context, listen: false)
                .toggleTaskCompletion(currentTask);
            _updateTask();
          },
          backgroundColor: currentTask.isCompleted ? Colors.grey : Colors.green,
          textColor: Colors.white,
          icon: currentTask.isCompleted
              ? Icons.refresh_outlined
              : Icons.check_circle_outline,
        ),
        if (!currentTask.isCompleted) ...[
          const SizedBox(height: 12),
          CustomButton(
            text: 'Delete Task',
            onPressed: () => _showDeleteConfirmation(context),
            backgroundColor: Colors.red,
            textColor: Colors.white,
            icon: Icons.delete_outline,
          ),
        ],
      ],
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

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<TaskProvider>(context, listen: false)
          .deleteTask(currentTask.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
