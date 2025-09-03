import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/course_controller.dart';
import '../../domain/models/user.dart';
import '../../domain/models/course.dart'; // <-- Added import

class ListCoursePage extends StatefulWidget {
  // Removed isTeacherView from constructor, will use state instead
  const ListCoursePage({super.key});

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
    _courseController = Get.put(CourseController());
    //_currentUser = Get.find<User>();
    _currentUser = User(name: "Daniel", id: "1"); // <-- This line
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final allCourses = await _courseController.getCourses();
    setState(() {
      if (_isTeacherView) {
        _filteredCourses = allCourses
            .where((c) => c.teachersNames.contains(_currentUser.name))
            .toList();
      } else {
        _filteredCourses = allCourses
            .where((c) => c.studentsNames.contains(_currentUser.name))
            .toList();
      }
    });
  }

  void _switchView(bool teacherView) {
    setState(() {
      _isTeacherView = teacherView;
    });
    _loadCourses();
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
      body: ListView.builder(
        itemCount: _filteredCourses.length,
        itemBuilder: (context, index) {
          final course = _filteredCourses[index];
          return ListTile(
            title: Text(course.name),
            subtitle: Text(course.description),
            // ...other UI...
          );
        },
      ),
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
