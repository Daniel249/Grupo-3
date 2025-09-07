import 'dart:math';
import '../models/course.dart';
import '../repositories/i_course_repository.dart';

class CourseUseCase {
  late ICourseRepository repository;

  CourseUseCase(this.repository);

  Future<List<Course>> getCourses() async => await repository.getCourses();

  Future<void> addCourse(
    String name,
    String description,
    List<String> students,
    String teacher,
  ) async => await repository.addCourse(
    Course(
      id: Random().nextInt(10000),
      name: name,
      description: description,
      studentsNames: students,
      teacher: teacher,
    ),
  );

  Future<void> updateCourse(Course user) async =>
      await repository.updateCourse(user);

  Future<void> deleteCourse(Course user) async =>
      await repository.deleteCourse(user);

  //Future<void> deleteProducts() async => await repository.deleteProducts();
}
