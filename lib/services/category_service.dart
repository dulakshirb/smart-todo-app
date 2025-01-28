import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_todo_app/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new category
  Future<void> addCategory(
      String categoryName, Color categoryColor, IconData categoryIcon) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .add({
        'categoryName': categoryName,
        'categoryColor': categoryColor.value,
        'categoryIcon': categoryIcon.codePoint
      });
    }
  }

  // Get all categories for the current user
  Future<List<CategoryModel>> getCategories() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    }
    return [];
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(categoryId)
          .delete();
    }
  }

  // Update a category
  Future<void> updateCategory(String categoryId, String categoryName,
      Color categoryColor, IconData categoryIcon) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(categoryId)
          .update({
        'categoryName': categoryName,
        'categoryColor': categoryColor.value,
        'categoryIcon': categoryIcon.codePoint
      });
    }
  }
}
