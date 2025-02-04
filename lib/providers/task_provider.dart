import 'package:dd_smart_todo_app/models/task_model.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/services/notification_service.dart';
import 'package:dd_smart_todo_app/services/task_service.dart';
import 'package:dd_smart_todo_app/utils/date_utils.dart';
import 'package:flutter/material.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  final CategoryProvider categoryProvider;
  List<TaskModel> _tasks = [];
  String? _userId;
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider({required this.categoryProvider});

  void updateUserId(String? userId) {
    _userId = userId;
    if (userId != null) {
      loadTasks(_userId!);
    } else {
      _tasks = [];
      notifyListeners();
    }
  }

  List<TaskModel> getTasksByCategory(String categoryId) {
    if (categoryId == 'uncategorized') {
      final existingCategoryIds =
          categoryProvider.categories.map((c) => c.id).toSet();
      return _tasks
          .where((task) =>
              task.categoryId == 'uncategorized' ||
              !existingCategoryIds.contains(task.categoryId))
          .toList();
    }
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  List<TaskModel> get incompleteTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  List<TaskModel> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  Future<void> loadTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasksByUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final newTask = await _taskService.createTask(task);
      _tasks.add(newTask);
      notifyListeners();

      // Schedule notification
      final dueDateTime = DateTimeUtils.combineDateAndTime(
        newTask.dueDate,
        newTask.dueTime,
      );

      await NotificationService().scheduleTaskReminder(
        taskId: newTask.id,
        title: newTask.title,
        description: newTask.description,
        dueDate: dueDateTime,
      );

      return newTask;
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _taskService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();

        // Cancel existing notification and schedule new one if not completed
        await NotificationService().cancelTaskReminder(task.id);
        if (!task.isCompleted) {
          final dueDateTime = DateTimeUtils.combineDateAndTime(
            task.dueDate,
            task.dueTime,
          );

          await NotificationService().scheduleTaskReminder(
            taskId: task.id,
            title: task.title,
            description: task.description,
            dueDate: dueDateTime,
          );
        }
      }
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    try {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      await updateTask(updatedTask);

      // Cancel notification if task is completed
      if (updatedTask.isCompleted) {
        await NotificationService().cancelTaskReminder(task.id);
      }
    } catch (e) {
      print('Error toggling task completion: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();

      // Cancel notification
      await NotificationService().cancelTaskReminder(taskId);
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  List<TaskModel> searchTasks(String query) {
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
