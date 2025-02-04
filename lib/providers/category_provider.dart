import 'package:dd_smart_todo_app/models/category_model.dart';
import 'package:dd_smart_todo_app/services/category_service.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<CategoryModel> _categories = [];
  String? _userId;
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  void updateUserId(String? userId) {
    _userId = userId;
    if (userId != null) {
      loadCategories(_userId!);
    } else {
      _categories = [];
      notifyListeners();
    }
  }

  Future<void> loadCategories(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategoriesByUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final newCategory = await _categoryService.createCategory(category);
      _categories.add(newCategory);
      notifyListeners();
      return newCategory;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _categoryService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoryService.deleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
