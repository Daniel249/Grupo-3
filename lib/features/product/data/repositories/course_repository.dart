import '../datasources/remote_course_source.dart';
import '../../domain/models/course.dart';

class CourseRepository {
  final RemoteCourseSource remoteCourseSource;

  CourseRepository(this.remoteCourseSource);

  Future<List<Course>> getCourses() => remoteCourseSource.getCourses();

  Future<bool> addCourse(Course course) => remoteCourseSource.addCourse(course);

  Future<bool> updateCourse(Course course) => remoteCourseSource.updateCourse(course);

  Future<bool> deleteCourse(Course course) => remoteCourseSource.deleteCourse(course);

  Future<bool> deleteCourses() => remoteCourseSource.deleteCourses();
}