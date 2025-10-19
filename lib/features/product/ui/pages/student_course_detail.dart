import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/category_controller.dart';
import '../controller/group_controller.dart';
import '../../domain/models/course.dart';
import '../../domain/models/user.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final Course course;
  final User currentUser;

  const StudentCourseDetailScreen({
    super.key,
    required this.course,
    required this.currentUser,
  });

  @override
  State<StudentCourseDetailScreen> createState() =>
      _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState extends State<StudentCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CategoryController _categoryController = Get.find<CategoryController>();
  final GroupController _groupController = Get.find<GroupController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _categoryController.getCategories(widget.course.id);
    _groupController.getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name),
        leading: BackButton(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Descripción'),
            Tab(text: 'Grupos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DescriptionTab(course: widget.course),
          _GroupsTab(course: widget.course, currentUser: widget.currentUser),
        ],
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  final Course course;
  const _DescriptionTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text(
            'Profesor: ${course.teacher}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _GroupsTab extends StatefulWidget {
  final Course course;
  final User currentUser;
  const _GroupsTab({required this.course, required this.currentUser});

  @override
  State<_GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<_GroupsTab> {
  final CategoryController _categoryController = Get.find<CategoryController>();
  final GroupController _groupController = Get.find<GroupController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = _categoryController.categories
          .where((cat) => cat.courseID == widget.course.id)
          .toList();

      // Filter groups that contain the current user
      final userGroups = _groupController.groups.where((group) {
        return group.studentsNames.contains(widget.currentUser.name);
      }).toList();

      // Map groups to their display data with category names
      final displayGroups = userGroups.map((group) {
        // Find the category for this group
        final category = categories.firstWhereOrNull(
          (cat) => cat.id == group.categoryId,
        );
        final categoryName = category?.name ?? 'Unknown';

        return {
          'group': group,
          'category': category,
          'displayName': '$categoryName - ${group.name}',
        };
      }).toList();

      return Column(
        children: [
          Expanded(
            child: displayGroups.isEmpty
                ? const Center(child: Text('No perteneces a ningún grupo.'))
                : ListView.builder(
                    itemCount: displayGroups.length,
                    itemBuilder: (context, index) {
                      final data = displayGroups[index];
                      final group = data['group'] as Group;
                      final category = data['category'] as Category?;
                      final displayName = data['displayName'] as String;

                      return ListTile(
                        title: Text(displayName),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(
                                categoryName: category?.name ?? 'Unknown',
                                group: group,
                                category: category,
                                currentUser: widget.currentUser,
                                course: widget.course,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.group_add),
              label: const Text('Agregarme a un grupo'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JoinGroupScreen(
                      course: widget.course,
                      currentUser: widget.currentUser,
                    ),
                  ),
                );
                await _groupController.getGroups();
                await _categoryController.getCategories(widget.course.id);
                if (mounted) setState(() {});
              },
            ),
          ),
        ],
      );
    });
  }
}

class GroupDetailScreen extends StatelessWidget {
  final String categoryName;
  final Group group;
  final Category? category;
  final User currentUser;
  final Course course;

  const GroupDetailScreen({
    super.key,
    required this.categoryName,
    required this.group,
    this.category,
    required this.currentUser,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$categoryName - ${group.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Integrantes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...group.studentsNames.map((s) => ListTile(title: Text(s))),
          ],
        ),
      ),
    );
  }
}

class JoinGroupScreen extends StatelessWidget {
  final Course course;
  final User currentUser;
  JoinGroupScreen({required this.course, required this.currentUser});

  final CategoryController _categoryController = Get.find<CategoryController>();
  final GroupController _groupController = Get.find<GroupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a un grupo')),
      body: Obx(() {
        final categories = _categoryController.categories
            .where((cat) => cat.courseID == course.id)
            .toList();

        // Get all groups for this course through GroupController
        final courseGroups = _groupController.groups.where((group) {
          // Check if the group's category belongs to this course
          final category = categories.firstWhereOrNull(
            (cat) => cat.id == group.categoryId,
          );
          return category != null;
        }).toList();

        // Filter out groups where user already is a member
        final availableGroups = courseGroups.where((group) {
          return !group.studentsNames.contains(currentUser.name);
        }).toList();

        // Map groups to display data with category names
        final displayGroups = availableGroups.map((group) {
          final category = categories.firstWhereOrNull(
            (cat) => cat.id == group.categoryId,
          );
          return {
            'group': group,
            'category': category,
            'displayName': '${category?.name ?? 'Unknown'} - ${group.name}',
          };
        }).toList();

        if (displayGroups.isEmpty) {
          return const Center(child: Text('No hay grupos disponibles.'));
        }

        return ListView.builder(
          itemCount: displayGroups.length,
          itemBuilder: (context, index) {
            final data = displayGroups[index];
            final group = data['group'] as Group;
            final displayName = data['displayName'] as String;

            return ListTile(
              title: Text(displayName),
              onTap: () async {
                final joined = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Unirse a $displayName'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Integrantes:'),
                        ...group.studentsNames.map((s) => Text(s)),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Add user to the group
                          if (!group.studentsNames.contains(currentUser.name)) {
                            group.studentsNames.add(currentUser.name);
                            await _groupController.updateGroup(group);
                          }
                          Navigator.pop(context, true); // Cierra el diálogo
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                );
                if (joined == true) {
                  Navigator.pop(context); // Regresa a la pantalla anterior
                }
              },
            );
          },
        );
      }),
    );
  }
}
