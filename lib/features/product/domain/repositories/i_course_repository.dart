import '../models/course.dart';

abstract class ICourseRepository {
  Future<List<Course>> getCourses();

  Future<bool> addCourse(Course c);

  Future<bool> updateCourse(Course c);

  Future<bool> deleteCourse(Course c);

  //Future<bool> deleteProducts();
}
