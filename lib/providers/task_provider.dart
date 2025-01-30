import 'package:flutter/material.dart';
import 'package:smart_todo_app/models/task_model.dart';
import 'package:smart_todo_app/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Load tasks from Firestore
  Future<void> loadTasks(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(categoryId);
      _sortTasks(); // Sort tasks after loading
    } catch (e) {
      print('Error loading tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Sort tasks by priority and due date/time
  void _sortTasks() {
    _tasks.sort((a, b) {
      final priorityOrder = {'High': 1, 'Medium': 2, 'Low': 3};
      final aPriority = priorityOrder[a.priority] ?? 2;
      final bPriority = priorityOrder[b.priority] ?? 2;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      final aDateTime = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day,
          a.dueTime.hour, a.dueTime.minute);
      final bDateTime = DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day,
          b.dueTime.hour, b.dueTime.minute);

      return aDateTime.compareTo(bDateTime);
    });
  }

  // Add a new task
  Future<void> addTask(TaskModel task) async {
    await _taskService.addTask(task);
    await loadTasks(task.categoryId);
    notifyListeners();
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    await _taskService.updateTask(task);

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId, String categoryId) async {
    await _taskService.deleteTask(taskId);
    await loadTasks(categoryId);
    notifyListeners();
  }

  // Get task count for a category
  Future<int> getTaskCount(String categoryId) async {
    return await _taskService.getTaskCount(categoryId);
  }
}
