import 'package:f_clean_template/features/product/domain/repositories/i_course_repository.dart';
import '../datasources/i_course_source.dart';
import '../datasources/remote_course_source.dart';
import '../../domain/models/course.dart';

class CourseRepository implements ICourseRepository {
  final ICourseSource remoteCourseSource;

  CourseRepository(this.remoteCourseSource);

  @override
  Future<List<Course>> getCourses() async => remoteCourseSource.getCourses();

  @override
  Future<bool> addCourse(Course course) async =>
      remoteCourseSource.addCourse(course);

  @override
  Future<bool> updateCourse(Course course) async =>
      remoteCourseSource.updateCourse(course);

  @override
  Future<bool> deleteCourse(Course course) async =>
      remoteCourseSource.deleteCourse(course);

  Future<bool> deleteCourses() async => remoteCourseSource.deleteCourses();
}
