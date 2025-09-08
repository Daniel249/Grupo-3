//import 'dart:math';
import '../../../domain/models/course.dart';
import '../i_course_source.dart';

class LocalCourseSource implements ICourseSource {
  final List<Course> _courses = <Course>[];

  LocalCourseSource() {
    _courses.add(
      Course(
        id: 2,
        name: 'Course 1',
        description: 'Description 1',
        studentsNames: ['Alice', 'Bob', 'Daniel'],
        teacher: 'Daniel',
      ),
    );
    _courses.add(
      Course(
        id: 1,
        name: 'Course 2',
        description: 'Description 1',
        studentsNames: ['Alice2', 'Bob2', 'Daniel'],
        teacher: 'Smith',
      ),
    );
  }

  @override
  Future<List<Course>> getCourses() => Future.value(_courses);

  @override
  Future<bool> addCourse(Course course) {
    _courses.add(course);
    return Future.value(true);
  }

  @override
  Future<bool> updateCourse(Course course) async {
    int index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteCourse(Course course) async {
    _courses.removeWhere((c) => c.id == course.id);
    return true;
  }

  @override
  Future<bool> deleteCourses() async {
    _courses.clear();
    return true;
  }
}
