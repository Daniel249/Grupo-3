import '../models/course.dart';
import '../repositories/i_course_repository.dart';

class CourseUseCase {
  late ICourseRepository repository;

  CourseUseCase(this.repository);

  Future<List<Course>> getCourses() async => await repository.getCourses();

  Future<void> addCourse(String name, String description) async =>
      await repository.addCourse(Course(name: name, description: description));

  Future<void> updateCourse(Course user) async =>
      await repository.updateCourse(user);

  Future<void> deleteCourse(Course user) async =>
      await repository.deleteCourse(user);

  //Future<void> deleteProducts() async => await repository.deleteProducts();
}
