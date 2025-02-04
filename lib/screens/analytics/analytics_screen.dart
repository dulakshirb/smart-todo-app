import 'package:dd_smart_todo_app/widgets/analytics/category_distrubution_chart.dart';
import 'package:dd_smart_todo_app/widgets/analytics/completion_trend_card.dart';
import 'package:dd_smart_todo_app/widgets/analytics/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _StatisticsSection(),
          const SizedBox(height: 24),
          const Text(
            'Category Distribution',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const CategoryDistributionChart(),
          const SizedBox(height: 24),
          const Text(
            'Completion Trend',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const CompletionTrendChart(),
        ],
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final totalTasks = taskProvider.tasks.length;
    final completedTasks =
        taskProvider.tasks.where((task) => task.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final categories = categoryProvider.categories.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Total Tasks',
          value: totalTasks.toString(),
          icon: Icons.task,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Completed',
          value: completedTasks.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatCard(
          title: 'Pending',
          value: pendingTasks.toString(),
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Categories',
          value: categories.toString(),
          icon: Icons.category,
          color: Colors.purple,
        ),
      ],
    );
  }
}
