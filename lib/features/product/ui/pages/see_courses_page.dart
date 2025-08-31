import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'course_creation_page.dart';

class ListCoursePage extends StatefulWidget {
  const ListCoursePage({super.key});

  @override
  State<ListCoursePage> createState() => _ListCoursePageState();
}

class _ListCoursePageState extends State<ListCoursePage> {
  // You can manage this via a controller too
  final RxString currentSection = 'student'.obs;

  // Mock data
  final studentCourses = [
    'Course 1',
    'Course 2',
    'Course 3',
    'Course 4',
    'Course 5',
  ];
  final teacherCourses = ['Course 1', 'Course 2', 'Course 3'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isStudent = currentSection.value == 'student';
      final courses = isStudent ? studentCourses : teacherCourses;

      return Scaffold(
        appBar: AppBar(
          title: Text(isStudent ? 'Student' : 'Teacher'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                // profile screen (if you have it)
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFFEDE7F6)),
                child: Text('Sections', style: TextStyle(fontSize: 20)),
              ),
              _drawerItem(
                icon: Icons.computer,
                label: 'Student',
                selected: isStudent,
                onTap: () {
                  currentSection.value = 'student';
                  Get.back(); // closes drawer
                },
              ),
              _drawerItem(
                icon: Icons.play_arrow,
                label: 'Teacher',
                selected: !isStudent,
                onTap: () {
                  currentSection.value = 'teacher';
                  Get.back();
                },
              ),
              const Divider(),
              _drawerItem(
                icon: Icons.favorite,
                label: 'Profile',
                onTap: () {
                  // Navigate to profile
                  // Get.to(() => const ProfilePage());
                },
              ),
              _drawerItem(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  // Get.to(() => const SettingsPage());
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'My Courses',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      color: Colors.deepPurple.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: const Text('A'),
                        ),
                        title: Text(course),
                        trailing: const Icon(
                          Icons.check_box,
                          color: Colors.deepPurple,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Course'),
                  onPressed: () {
                    if (isStudent) {
                      // Go to student course creation
                      // Get.to(() => const StudentCourseCreationPage());
                    } else {
                      // Go to teacher course creation
                      Get.to(() => const TeacherCourseCreationPage());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }
}
