//import 'dart:ffi';

import 'activity.dart';
import 'category.dart';

class Course {
  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.studentsNames,
    required this.teacher,
    this.activities,
    this.categories,
  });

  String id;
  String name;
  String description;
  List<String> studentsNames = [];
  String teacher;
  List<Activity>? activities;
  List<Category>? categories;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'] as String,
      name: json['Name'] as String,
      description: json['Description'] as String? ?? '',
      teacher: json['Teacher'] as String? ?? '',
      studentsNames: List<String>.from(json['Students'] ?? []),
    );
  }
}
