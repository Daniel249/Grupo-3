import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/course_controller.dart';
import '../../domain/models/user.dart';
import '../../domain/models/course.dart';

class CourseDeleteUpdatePage extends StatefulWidget {
  final User currentUser;
  const CourseDeleteUpdatePage({super.key, required this.currentUser});

  @override
  State<CourseDeleteUpdatePage> createState() => _CourseDeleteUpdatePage();
}

class _CourseDeleteUpdatePage extends State<CourseDeleteUpdatePage> {
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final students = <String>[].obs;

  Course? selectedCourse;

  void _searchCourse() {
    final courseName = searchController.text.trim();
    if (courseName.isEmpty) return;

    final courseController = Get.find<CourseController>();
    final foundCourse = courseController.courses.firstWhereOrNull(
      (c) => c.name == courseName,
    );

    if (foundCourse != null) {
      setState(() {
        selectedCourse = foundCourse;
        nameController.text = foundCourse.name;
        descriptionController.text = foundCourse.description;
        students.assignAll(foundCourse.studentsNames);
      });
    } else {
      setState(() {
        selectedCourse = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Course '$courseName' not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Course'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Enter course name to search",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchCourse,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mostrar solo si se encontró un curso
              if (selectedCourse != null) ...[
                _inputField(
                  label: 'Course Name',
                  controller: nameController,
                  hint: 'Edit course name',
                ),
                const SizedBox(height: 16),
                _inputField(
                  label: 'Description',
                  controller: descriptionController,
                  hint: 'Edit description',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Students",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Lista de estudiantes
                Obx(
                  () => Column(
                    children: students.isEmpty
                        ? [const Text("No students")]
                        : students
                              .map(
                                (s) => ListTile(
                                  title: Text(s),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => students.remove(s),
                                  ),
                                ),
                              )
                              .toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón para añadir estudiante
                ElevatedButton.icon(
                  onPressed: () async {
                    final studentName = await _showAddStudentDialog(context);
                    if (studentName != null && studentName.isNotEmpty) {
                      students.add(studentName);
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("Add Student"),
                ),
                const SizedBox(height: 32),

                // Botones de acciones: eliminar y guardar cambios
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                        onPressed: () {
                          final courseController = Get.find<CourseController>();
                          courseController.deleteCourse(selectedCourse!);
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text("Save Changes"),
                        onPressed: () {
                          final updatedCourse = Course(
                            id: selectedCourse!.id,
                            name: nameController.text,
                            description: descriptionController.text,
                            studentsNames: students.toList(),
                            teacher: selectedCourse!
                                .teacher, // ✅ se mantiene el profesor original
                          );

                          final courseController = Get.find<CourseController>();
                          courseController.updateCourse(updatedCourse);

                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<String?> _showAddStudentDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Student'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Student name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
