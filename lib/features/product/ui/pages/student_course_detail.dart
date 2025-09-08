import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/category_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _categoryController.getCategories();
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = _categoryController.categories
          .where((cat) => cat.courseID == widget.course.id)
          .toList();

      final userGroups = <Map<String, dynamic>>[];
      for (final cat in categories) {
        for (int i = 0; i < cat.groups.length; i++) {
          final group = cat.groups[i];
          if (group.students.contains(widget.currentUser.name)) {
            userGroups.add({
              'category': cat,
              'group': group,
              'groupNumber': i + 1,
            });
          }
        }
      }

      return Column(
        children: [
          Expanded(
            child: userGroups.isEmpty
                ? const Center(child: Text('No perteneces a ningún grupo.'))
                : ListView.builder(
                    itemCount: userGroups.length,
                    itemBuilder: (context, index) {
                      final cat = userGroups[index]['category'] as Category;
                      final group = userGroups[index]['group'] as Group;
                      final groupNumber = userGroups[index]['groupNumber'];
                      final groupName = '${cat.name}-$groupNumber';
                      return ListTile(
                        title: Text(groupName),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(
                                groupName: groupName,
                                group: group,
                                category: cat,
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
                await _categoryController.getCategories();
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
  final String groupName;
  final Group group;
  final Category category;
  final User currentUser;
  final Course course;

  const GroupDetailScreen({
    super.key,
    required this.groupName,
    required this.group,
    required this.category,
    required this.currentUser,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Integrantes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...group.students.map((s) => ListTile(title: Text(s))),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a un grupo')),
      body: Obx(() {
        final categories = _categoryController.categories
            .where((cat) => cat.courseID == course.id)
            .toList();

        // Encuentra los grupos donde el usuario YA está
        final Set<String> userGroupKeys = {};
        for (final cat in categories) {
          for (int i = 0; i < cat.groups.length; i++) {
            final group = cat.groups[i];
            if (group.students.contains(currentUser.name)) {
              userGroupKeys.add('${cat.id}-$i');
            }
          }
        }

        // Lista de todos los grupos donde NO está el usuario
        final availableGroups = <Map<String, dynamic>>[];
        for (final cat in categories) {
          for (int i = 0; i < cat.groups.length; i++) {
            final group = cat.groups[i];
            if (!group.students.contains(currentUser.name) &&
                !userGroupKeys.contains('${cat.id}-$i')) {
              availableGroups.add({
                'category': cat,
                'group': group,
                'groupNumber': i + 1,
              });
            }
          }
        }

        if (availableGroups.isEmpty) {
          return const Center(child: Text('No hay grupos disponibles.'));
        }

        return ListView.builder(
          itemCount: availableGroups.length,
          itemBuilder: (context, index) {
            final cat = availableGroups[index]['category'] as Category;
            final group = availableGroups[index]['group'] as Group;
            final groupNumber = availableGroups[index]['groupNumber'];
            final groupName = '${cat.name}-$groupNumber';
            return ListTile(
              title: Text(groupName),
              onTap: () async {
                final joined = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Unirse a $groupName'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Integrantes:'),
                        ...group.students.map((s) => Text(s)),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Lógica para agregarse al grupo
                          if (!group.students.contains(currentUser.name)) {
                            group.students.add(currentUser.name);
                            await _categoryController.updateCategory(cat);
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
