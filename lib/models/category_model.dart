import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_todo_app/utils/colors.dart';

class CategoryModel {
  String id;
  String categoryName;
  Color categoryColor;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.categoryColor,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      categoryName: data['categoryName'] ?? 'Uncategorized',
      categoryColor: Color(data['categoryColor'] ?? primaryColor),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryName': categoryName,
      'categoryColor': categoryColor.value,
    };
  }
}
