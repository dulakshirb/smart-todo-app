import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String categoryId;
  final DateTime dueDate;
  final String dueTime;
  final String priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.categoryId,
    required this.dueDate,
    required this.dueTime,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      dueTime: map['dueTime'] ?? '',
      priority: map['priority'] ?? 'low',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'categoryId': categoryId,
      'dueDate': Timestamp.fromDate(dueDate),
      'dueTime': dueTime,
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    String? categoryId,
    DateTime? dueDate,
    String? dueTime,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
