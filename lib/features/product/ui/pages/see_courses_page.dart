import 'package:f_clean_template/features/product/ui/pages/course_creation_page.dart';
import 'package:f_clean_template/features/product/ui/pages/course_delete_update_page.dart';
//import 'package:f_clean_template/features/product/ui/pages/course_view_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/course_controller.dart';
import '../../domain/models/user.dart';
import '../../domain/models/course.dart';
import 'package:f_clean_template/features/product/ui/pages/teacher_course_view.dart';
import 'join_course_screen.dart';
import 'student_course_detail.dart';

class ListCoursePage extends StatefulWidget {
  final User user;
  const ListCoursePage({super.key, required this.user});

  @override
  State<ListCoursePage> createState() => _ListCoursePageState();
}

class _ListCoursePageState extends State<ListCoursePage> {
  late final CourseController _courseController;
  late final User _currentUser;
  List<Course> _filteredCourses = [];
  bool _isTeacherView = false; // Default to student view

  @override
  void initState() {
    super.initState();
    _courseController = Get.find<CourseController>();
    _currentUser = widget.user; // Usa el user recibido, elimina el mockup
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    await _courseController.getCourses();
    final allCourses = _courseController.courses;
    setState(() {
      if (_isTeacherView) {
        _filteredCourses = allCourses
            .where((c) => c.teacher == _currentUser.name)
            .toList();
      } else {
        _filteredCourses = allCourses
            .where((c) => c.studentsNames.contains(_currentUser.name))
            .toList();
      }
    });
  }

  void _switchView(bool teacherView) {
    bool flag = false;
    setState(() {
      if (_isTeacherView != teacherView) flag = true;
      _isTeacherView = teacherView;
    });
    if (flag) _loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isTeacherView ? 'Teacher' : 'Student'),
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
              selected: !_isTeacherView,
              onTap: () {
                Navigator.pop(context);
                _switchView(false);
              },
            ),
            _drawerItem(
              icon: Icons.play_arrow,
              label: 'Teacher',
              selected: _isTeacherView,
              onTap: () {
                Navigator.pop(context);
                _switchView(true);
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
      body: _filteredCourses.isEmpty
          ? const Center(child: Text("There're no courses available"))
          : Stack(
              children: [
                ListView.builder(
                  itemCount: _filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = _filteredCourses[index];
                    return ListTile(
                      title: Text(course.name),
                      subtitle: Text(course.description),
                      onTap: () {
                        if (_isTeacherView) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeacherCourseViewPage(
                                course: course,
                                currentUser: _currentUser,
                              ),
                            ),
                          ).then((_) => _loadCourses());
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentCourseDetailScreen(
                                course: course,
                                currentUser: _currentUser,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                if (!_isTeacherView)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Unirse a un curso'),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                JoinCourseScreen(currentUser: _currentUser),
                          ),
                        );
                        await _loadCourses(); // Refresca la lista al volver
                      },
                    ),
                  ),
              ],
            ),
      floatingActionButton: _isTeacherView
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "btn1",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDeleteUpdatePage(
                          currentUser: _currentUser,
                        ), // Ejemplo
                      ),
                    ).then((_) => _loadCourses());
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: "btn2",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherCourseCreationPage(
                          currentUser: _currentUser,
                        ),
                      ),
                    ).then((_) => _loadCourses());
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            )
          : null,
    );
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
