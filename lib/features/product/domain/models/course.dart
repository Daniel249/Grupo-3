class Course {
  Course({
    this.id,
    required this.name,
    required this.description,
    required this.studentsNames,
    required this.teacher,
  });

  String? id;
  String name;
  String description;
  List<String> studentsNames = [];
  String teacher;
}
