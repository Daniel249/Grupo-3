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

  int id;
  String name;
  String description;
  List<String> studentsNames = [];
  String teacher;
  List<Activity>? activities;
  List<Category>? categories;
}
