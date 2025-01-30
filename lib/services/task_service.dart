import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_todo_app/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new task
  Future<void> addTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add(task.toFirestore());
    }
  }

  // Get all tasks for the current user
  Future<List<TaskModel>> getTasks(String categoryId) async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    }
    return [];
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .update(task.toFirestore());
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
    }
  }

  // Get task count for a category
  Future<int> getTaskCount(String categoryId) async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.size;
    }
    return 0;
  }
}
