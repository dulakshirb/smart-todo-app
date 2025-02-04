import 'package:dd_smart_todo_app/models/category_model.dart';
import 'package:flutter/material.dart';

class Constants {
  static const List<String> priorityLevels = ['low', 'medium', 'high'];

  static const Map<String, Color> priorityColors = {
    'Low': Colors.green,
    'Medium': Colors.orange,
    'High': Colors.red,
  };

  static List<Color> categoryColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  static List<IconData> categoryIcons = [
    Icons.work,
    Icons.home,
    Icons.school,
    Icons.shopping_cart,
    Icons.favorite,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.local_airport,
  ];

  static CategoryModel getUncategorizedCategory(String userId) {
    return CategoryModel(
      id: 'uncategorized',
      name: 'Uncategorized',
      color: Colors.grey,
      icon: Icons.folder_outlined,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static const uncategorizedStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  static var uncategorizedContainerDecoration = BoxDecoration(
    color: Colors.grey,
    borderRadius: BorderRadius.circular(8),
  );
}
