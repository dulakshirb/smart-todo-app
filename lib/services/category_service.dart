import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  // Get all categories for a user
  Future<List<CategoryModel>> getCategoriesByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      rethrow;
    }
  }

  // Create a new category
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final now = DateTime.now().toUtc();
      final categoryData = {
        ...category.toMap(),
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection(_collection).add(categoryData);

      final doc = await docRef.get();
      return CategoryModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  // Update existing category
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final now = DateTime.now().toUtc();
      final categoryData = {
        ...category.toMap(),
        'updatedAt': Timestamp.fromDate(now),
      };

      await _firestore
          .collection(_collection)
          .doc(category.id)
          .update(categoryData);

      return category.copyWith(updatedAt: now);
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Start a batch
      final batch = _firestore.batch();

      // Get all tasks with this category
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      // Delete all tasks in this category
      for (var doc in tasksSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the category
      batch.delete(_firestore.collection(_collection).doc(categoryId));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(categoryId).get();

      if (doc.exists) {
        return CategoryModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting category by ID: $e');
      rethrow;
    }
  }

  // Check if category name exists for user
  Future<bool> categoryNameExists(String userId, String name) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('name', isEqualTo: name)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking category name: $e');
      rethrow;
    }
  }

  // Get category statistics
  Future<Map<String, dynamic>> getCategoryStats(String categoryId) async {
    try {
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      final totalTasks = tasksSnapshot.docs.length;
      final completedTasks = tasksSnapshot.docs
          .where((doc) => doc.data()['isCompleted'] == true)
          .length;

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'completionRate': totalTasks > 0
            ? '${(completedTasks / totalTasks * 100).toStringAsFixed(1)}%'
            : '0%',
      };
    } catch (e) {
      print('Error getting category statistics: $e');
      rethrow;
    }
  }
}
