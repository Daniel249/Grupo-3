// lib/domain/models/course.dart
class Course {
  final int id;
  final String code;
  final String title;
  final String description;
  final String instructor;
  final int credits;

  Course({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.instructor,
    required this.credits,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      credits: json['credits'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'instructor': instructor,
      'credits': credits,
    };
  }
}
