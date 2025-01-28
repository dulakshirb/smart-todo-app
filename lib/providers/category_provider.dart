import 'package:flutter/material.dart';
import 'package:smart_todo_app/models/category_model.dart';
import 'package:smart_todo_app/services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  // Load categories from Firestore
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      print('Error loading categories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(
      String categoryName, Color categoryColor, IconData categoryIcon) async {
    await _categoryService.addCategory(
      categoryName,
      categoryColor,
      categoryIcon,
    );
    await loadCategories();
    notifyListeners();
  }
}
