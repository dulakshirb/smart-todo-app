
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class CompletionTrendChart extends StatelessWidget {
  const CompletionTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final completionData = _getCompletionData(taskProvider);

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _getWeekDay(value.toInt()),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: completionData,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getCompletionData(TaskProvider taskProvider) {
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final completedCount = taskProvider.tasks
          .where((task) =>
              task.isCompleted &&
              task.completedAt?.day == date.day &&
              task.completedAt?.month == date.month &&
              task.completedAt?.year == date.year)
          .length;
      return FlSpot(index.toDouble(), completedCount.toDouble());
    });
    return weekData;
  }

  String _getWeekDay(int index) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: 6 - index));
    return '${date.day}/${date.month}';
  }
}
