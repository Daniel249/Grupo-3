import 'dart:math';
import '../models/course.dart';
import '../repositories/i_course_repository.dart';

class CourseUseCase {
  late ICourseRepository repository;

  CourseUseCase(this.repository);

  Future<List<Course>> getCourses() async => await repository.getCourses();

  Future<void> addCourse(
    String name,
    String desc,
    List<String> students,
    String teacher,
  ) async {
    final newCourse = Course(
      id: Random().nextInt(100000).toString(),
      name: name,
      description: desc,
      studentsNames: students,
      teacher: teacher,
    );
    await repository.addCourse(newCourse);
  }

  Future<void> updateCourse(Course user) async =>
      await repository.updateCourse(user);

  Future<void> deleteCourse(Course user) async =>
      await repository.deleteCourse(user);

  //Future<void> deleteProducts() async => await repository.deleteProducts();
}
