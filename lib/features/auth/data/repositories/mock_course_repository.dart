// lib/data/repository/mock_course_repository.dart
import 'dart:async';
import '../../domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';

class MockCourseRepository implements ICourseRepository {
  @override
  Future<List<Course>> getEnrolledCourses(String studentEmail) async {
    // Simula latencia de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Para demostrar, devolvemos algunos cursos "mock".
    // En uso real, harías una llamada HTTP o consulta BD.
    if (studentEmail.contains('no-cursos')) {
      return [];
    }

    return [
      Course(
        id: 1,
        code: 'MAT101',
        title: 'Cálculo I',
        description: 'Introducción al cálculo diferencial e integral.',
        instructor: 'Dra. Pérez',
        credits: 4,
      ),
      Course(
        id: 2,
        code: 'PROG202',
        title: 'Programación en Dart',
        description: 'Fundamentos de programación con Dart y Flutter.',
        instructor: 'Ing. Gómez',
        credits: 3,
      ),
      Course(
        id: 3,
        code: 'FIS150',
        title: 'Física General',
        description: 'Mecánica clásica y aplicaciones.',
        instructor: 'Dr. Ramírez',
        credits: 4,
      ),
    ];
  }
}
