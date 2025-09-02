import '../../../domain/models/course.dart';
import '../i_course_source.dart';

class LocalCourseSource implements ICourseSource {
  final List<Course> _courses = [];

  @override
  Future<List<Course>> getCourses() async => _courses;

  @override
  Future<bool> addCourse(Course course) async {
    _courses.add(course);
    return true;
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
