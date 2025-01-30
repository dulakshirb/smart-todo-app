import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskModel {
  String id;
  String title;
  String description;
  DateTime dueDate;
  TimeOfDay dueTime;
  String priority;
  bool isCompleted;
  String categoryId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.priority,
    this.isCompleted = false,
    required this.categoryId,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      dueTime: _timeFromInt(data['dueTime']),
      priority: data['priority'] ?? 'Medium',
      isCompleted: data['isCompleted'] ?? false,
      categoryId: data['categoryId'] ?? '',
    );
  }

  static TimeOfDay _timeFromInt(int time) {
    final hour = time ~/ 60;
    final minute = time % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'dueTime': dueTime.hour * 60 + dueTime.minute,
      'priority': priority,
      'isCompleted': isCompleted,
      'categoryId': categoryId,
    };
  }
}
