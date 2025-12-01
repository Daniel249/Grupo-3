import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/course_controller.dart';
import '../../domain/models/user.dart';
import '../../domain/models/course.dart';

class JoinCourseScreen extends StatefulWidget {
  final User currentUser;
  const JoinCourseScreen({super.key, required this.currentUser});

  @override
  State<JoinCourseScreen> createState() => _JoinCourseScreenState();
}

class _JoinCourseScreenState extends State<JoinCourseScreen> {
  late final CourseController _courseController;
  List<Course> _allCourses = [];

  @override
  void initState() {
    super.initState();
    _courseController = Get.find<CourseController>();
    _loadAllCourses();
  }

  Future<void> _loadAllCourses() async {
    await _courseController.getCourses();
    setState(() {
      _allCourses = _courseController.courses
          .where(
            (course) => !course.studentsNames.contains(widget.currentUser.name),
          )
          .toList();
    });
  }

  void _showJoinDialog(Course course) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unirse a ${course.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Deseas unirte a este curso?'),
            const SizedBox(height: 8),
            Text(
              'Profesor: ${course.teacher}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(course.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Crear nuevo objeto Course con el estudiante agregado
              final updatedStudents = [...course.studentsNames];
              if (!updatedStudents.contains(widget.currentUser.name)) {
                updatedStudents.add(widget.currentUser.name);
              }
              final updatedCourse = Course(
                id: course.id,
                name: course.name,
                description: course.description,
                studentsNames: updatedStudents,
                teacher: course.teacher,
                activities: course.activities,
                categories: course.categories,
              );
              await _courseController.updateCourse(updatedCourse);
              Navigator.pop(context, true);
            },
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
    if (result == true) {
      // Opcional: muestra un mensaje de éxito
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('¡Te has unido al curso!')));
      // Al volver, la lista de cursos del estudiante se actualizará
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Todos los cursos'),
      ),
      body: _allCourses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allCourses.length,
              itemBuilder: (context, index) {
                final course = _allCourses[index];
                return ListTile(
                  title: Text(course.name),
                  subtitle: Text('ID: ${course.id}'),
                  onTap: () => _showJoinDialog(course),
                );
              },
            ),
    );
  }
}
