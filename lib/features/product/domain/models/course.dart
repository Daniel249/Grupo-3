//import 'dart:ffi';

import 'dart:convert';
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

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    name: json['Name']?.toString() ?? json['name']?.toString() ?? '',
    description:
        json['Description']?.toString() ??
        json['description']?.toString() ??
        '',
    teacher: json['Teacher']?.toString() ?? json['teacher']?.toString() ?? '',
    studentsNames: _parseStudentNames(json),
  );

  static List<String> _parseStudentNames(Map<String, dynamic> json) {
    final students = json['Students'] ?? json['students'] ?? [];
    if (students is List) {
      return students.map((student) => student.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'Name': name,
    'Description': description,
    'Students': jsonEncode(studentsNames),
    'Teacher': teacher,
  };

  Map<String, dynamic> toJsonNoId() => {
    'Name': name,
    'Description': description,
    'Students': jsonEncode(studentsNames),
    'Teacher': teacher,
  };

  @override
  String toString() {
    return 'Course{id: $id, name: $name, description: $description, studentsNames: $studentsNames, teacher: $teacher, activities: $activities, categories: $categories}';
  }
}
