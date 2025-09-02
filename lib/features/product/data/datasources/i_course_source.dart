import '../../domain/models/course.dart';

abstract class ICourseSource {
  Future<List<Course>> getCourses();
  Future<bool> addCourse(Course course);
  Future<bool> updateCourse(Course course);
  Future<bool> deleteCourse(Course course);
  Future<bool> deleteCourses();
}
