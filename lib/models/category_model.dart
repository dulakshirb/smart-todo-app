import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: IconData(map['iconCode'] ?? 0x0, fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue'] ?? 0xFF000000),
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconCode': icon.codePoint,
      // ignore: deprecated_member_use
      'colorValue': color.value,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
