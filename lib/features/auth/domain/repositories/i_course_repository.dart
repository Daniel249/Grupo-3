import '../models/course.dart';

abstract class ICourseRepository {
  /// Obtiene la lista de cursos en los que está inscrito el estudiante
  /// identificado por su email (o id según tu sistema).
  Future<List<Course>> getEnrolledCourses(String studentEmail);
}
