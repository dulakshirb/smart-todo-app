import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  // Get all tasks for a user
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting tasks: $e');
      rethrow;
    }
  }

  // Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final now = DateTime.now().toUtc();
      final taskData = {
        ...task.toMap(),
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection(_collection).add(taskData);
      final doc = await docRef.get();

      return TaskModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  // Update existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final now = DateTime.now().toUtc();
      final taskData = {
        ...task.toMap(),
        'updatedAt': Timestamp.fromDate(now),
      };

      await _firestore.collection(_collection).doc(task.id).update(taskData);

      return task.copyWith(updatedAt: now);
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  // Toggle task completion status
  Future<TaskModel> toggleTaskCompletion(TaskModel task) async {
    try {
      final now = DateTime.now().toUtc();
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: now,
      );

      await _firestore.collection(_collection).doc(task.id).update({
        'isCompleted': updatedTask.isCompleted,
        'updatedAt': Timestamp.fromDate(now),
      });

      return updatedTask;
    } catch (e) {
      print('Error toggling task completion: $e');
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection(_collection).doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Get tasks by category
  Future<List<TaskModel>> getTasksByCategory(
      String userId, String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting tasks by category: $e');
      rethrow;
    }
  }

  // Get tasks by date range
  Future<List<TaskModel>> getTasksByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where(
            'dueDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting tasks by date range: $e');
      rethrow;
    }
  }
}
