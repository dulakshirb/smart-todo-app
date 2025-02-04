import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dd_smart_todo_app/utils/constants.dart';
import 'package:dd_smart_todo_app/providers/auth_provider.dart';

class CategoryDistributionChart extends StatelessWidget {
  const CategoryDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final authProvider = context.watch<AuthProvider>();

    // Get current user ID
    final userId = authProvider.currentUser?.id ?? '';

    // Early return if no tasks or no categories
    if (taskProvider.tasks.isEmpty) {
      return _buildEmptyState('No tasks available');
    }

    if (categoryProvider.categories.isEmpty) {
      return _buildEmptyState('No categories available');
    }

    final Map<String, Map<String, dynamic>> categoryData = {};
    int uncategorizedCount = 0;

    // Initialize category data
    for (final category in categoryProvider.categories) {
      categoryData[category.id] = {
        'name': category.name,
        'color': category.color,
        'count': 0,
      };
    }

    // Count tasks for each category
    for (final task in taskProvider.tasks) {
      if (categoryData.containsKey(task.categoryId)) {
        categoryData[task.categoryId]!['count'] =
            (categoryData[task.categoryId]!['count'] as int) + 1;
      } else {
        // Count uncategorized tasks
        uncategorizedCount++;
      }
    }

    // Add uncategorized to the map if there are any
    if (uncategorizedCount > 0) {
      final uncategorized = Constants.getUncategorizedCategory(userId);
      categoryData['uncategorized'] = {
        'name': uncategorized.name,
        'color': uncategorized.color,
        'count': uncategorizedCount,
      };
    }

    // Filter out categories with no tasks
    final activeCategoryData = Map.fromEntries(
      categoryData.entries.where((entry) => entry.value['count'] > 0),
    );

    if (activeCategoryData.isEmpty) {
      return _buildEmptyState('No task distribution data available');
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _createPieSections(activeCategoryData),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _buildLegendItems(activeCategoryData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieSections(
    Map<String, Map<String, dynamic>> data,
  ) {
    final total = data.values
        .fold<int>(0, (sum, category) => sum + (category['count'] as int));

    return data.entries.map((entry) {
      final category = entry.value;
      final count = category['count'] as int;
      final percentage = (count / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        value: count.toDouble(),
        title: '$percentage%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: category['color'] as Color,
      );
    }).toList();
  }

  List<Widget> _buildLegendItems(Map<String, Map<String, dynamic>> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) {
        if (a.key == 'uncategorized') return 1;
        if (b.key == 'uncategorized') return -1;
        return (b.value['count'] as int).compareTo(a.value['count'] as int);
      });

    return sortedEntries.map((entry) {
      final category = entry.value;
      final count = category['count'] as int;
      final name = category['name'] as String;
      final color = category['color'] as Color;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$name ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: entry.key == 'uncategorized'
                    ? FontWeight.normal
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
