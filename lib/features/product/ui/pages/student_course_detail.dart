import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/category_controller.dart';
import '../controller/group_controller.dart';
import '../controller/activity_controller.dart';
import '../../domain/models/course.dart';
import '../../domain/models/user.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';
import '../../domain/models/activity.dart';

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
  final ActivityController _activityController = Get.find<ActivityController>();

  @override
  void initState() {
    super.initState();
    _activityController.getActivities(widget.course.id);
  }

  Widget build(BuildContext context) {
    return Obx(() {
      final categories = _categoryController.categories
          .where((cat) => cat.courseID == widget.course.id)
          .toList();

      final activities = _activityController.activities;

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

        // Check if there are any active assessments for this category
        final hasActiveAssessment =
            category != null &&
            activities.any(
              (activity) =>
                  activity.category == category.id && activity.assessment,
            );

        return {
          'group': group,
          'category': category,
          'displayName': '$categoryName - ${group.name}',
          'hasActiveAssessment': hasActiveAssessment,
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
                      final hasActiveAssessment =
                          data['hasActiveAssessment'] as bool;

                      return ListTile(
                        title: Text(displayName),
                        trailing: hasActiveAssessment
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Active Assessment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : null,
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

class GroupDetailScreen extends StatefulWidget {
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
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final ActivityController _activityController = Get.find<ActivityController>();
  List<Activity> _categoryActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);

    await _activityController.getActivities(widget.course.id);

    // Filter activities for this category that have active assessments
    final activities = _activityController.activities
        .where(
          (activity) =>
              activity.category == widget.category?.id &&
              activity.assessment == true,
        )
        .toList();

    setState(() {
      _categoryActivities = activities;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} - ${widget.group.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Integrantes:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ...widget.group.studentsNames.map(
                    (s) => ListTile(title: Text(s)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Assessments:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _categoryActivities.isEmpty
                        ? const Center(
                            child: Text('No hay assessments activos'),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                border: TableBorder.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.blue.shade50,
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Activity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Category',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'My Average',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Group Average',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: _categoryActivities.map((activity) {
                                  final myAverage =
                                      activity.studentAverages?[widget
                                          .currentUser
                                          .name] ??
                                      0.0;

                                  // Calculate group average
                                  double groupSum = 0.0;
                                  int groupCount = 0;
                                  for (var studentName
                                      in widget.group.studentsNames) {
                                    final avg =
                                        activity
                                            .studentAverages?[studentName] ??
                                        0.0;
                                    if (avg > 0.0) {
                                      groupSum += avg;
                                      groupCount++;
                                    }
                                  }
                                  final groupAverage = groupCount > 0
                                      ? groupSum / groupCount
                                      : 0.0;

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(activity.name),
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AssessmentScreen(
                                                activity: activity,
                                                group: widget.group,
                                                currentUser: widget.currentUser,
                                              ),
                                            ),
                                          );
                                          _loadActivities();
                                        },
                                      ),
                                      DataCell(
                                        Text(widget.categoryName),
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AssessmentScreen(
                                                activity: activity,
                                                group: widget.group,
                                                currentUser: widget.currentUser,
                                              ),
                                            ),
                                          );
                                          _loadActivities();
                                        },
                                      ),
                                      DataCell(
                                        Text(
                                          myAverage == 0.0
                                              ? 'No Score'
                                              : myAverage.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: myAverage == 0.0
                                                ? Colors.grey
                                                : myAverage >= 4.0
                                                ? Colors.green
                                                : myAverage >= 3.0
                                                ? Colors.orange
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AssessmentScreen(
                                                activity: activity,
                                                group: widget.group,
                                                currentUser: widget.currentUser,
                                              ),
                                            ),
                                          );
                                          _loadActivities();
                                        },
                                      ),
                                      DataCell(
                                        Text(
                                          groupAverage == 0.0
                                              ? 'No Score'
                                              : groupAverage.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: groupAverage == 0.0
                                                ? Colors.grey
                                                : groupAverage >= 4.0
                                                ? Colors.green
                                                : groupAverage >= 3.0
                                                ? Colors.orange
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AssessmentScreen(
                                                activity: activity,
                                                group: widget.group,
                                                currentUser: widget.currentUser,
                                              ),
                                            ),
                                          );
                                          _loadActivities();
                                        },
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
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

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    Category? selectedCategory;

    // Get non-random categories
    final nonRandomCategories = _categoryController.categories
        .where((cat) => cat.courseID == course.id && !cat.isRandomSelection)
        .toList();

    if (nonRandomCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay categorías disponibles para crear grupos'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Crear Grupo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownMenu<Category>(
                  initialSelection: selectedCategory,
                  label: const Text('Categoría'),
                  expandedInsets: EdgeInsets.zero,
                  dropdownMenuEntries: nonRandomCategories.map((category) {
                    return DropdownMenuEntry<Category>(
                      value: category,
                      label: category.name,
                    );
                  }).toList(),
                  onSelected: (value) {
                    setStateDialog(() {
                      selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Grupo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCategory == null ||
                      nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor completa todos los campos'),
                      ),
                    );
                    return;
                  }

                  final newGroup = Group(
                    id: '0',
                    name: nameController.text.trim(),
                    studentsNames: [currentUser.name],
                    categoryId: selectedCategory!.id,
                  );

                  final success = await _groupController.addGroup(newGroup);

                  if (success) {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close JoinGroupScreen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al crear el grupo')),
                    );
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a un grupo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear Nuevo Grupo'),
              onPressed: () => _showCreateGroupDialog(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
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
                  'displayName':
                      '${category?.name ?? 'Unknown'} - ${group.name}',
                };
              }).toList();

              if (displayGroups.isEmpty) {
                return const Center(
                  child: Text('No hay grupos disponibles para unirse.'),
                );
              }

              return ListView.builder(
                itemCount: displayGroups.length,
                itemBuilder: (context, index) {
                  final data = displayGroups[index];
                  final group = data['group'] as Group;
                  final displayName = data['displayName'] as String;

                  return ListTile(
                    title: Text(displayName),
                    subtitle: Text('${group.studentsNames.length} miembros'),
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
                              ...group.studentsNames.map((s) => Text('• $s')),
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
                                if (!group.studentsNames.contains(
                                  currentUser.name,
                                )) {
                                  group.studentsNames.add(currentUser.name);
                                  await _groupController.updateGroup(group);
                                }
                                Navigator.pop(context, true); // Close dialog
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        ),
                      );
                      if (joined == true) {
                        Navigator.pop(context); // Return to previous screen
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Assessment Screen for evaluating group members
class AssessmentScreen extends StatefulWidget {
  final Activity activity;
  final Group group;
  final User currentUser;

  const AssessmentScreen({
    super.key,
    required this.activity,
    required this.group,
    required this.currentUser,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final ActivityController _activityController = Get.find<ActivityController>();

  // Store ratings for each student: studentName -> [punctuality, contributions, commitment, attitude]
  final Map<String, List<int?>> _ratings = {};

  List<String> get _membersToRate => widget.group.studentsNames
      .where((name) => name != widget.currentUser.name)
      .toList();

  @override
  void initState() {
    super.initState();
    // Initialize ratings map with null values
    for (var member in _membersToRate) {
      _ratings[member] = [null, null, null, null];
    }
  }

  bool _allRatingsComplete() {
    for (var ratings in _ratings.values) {
      if (ratings.contains(null)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submitRatings() async {
    if (!_allRatingsComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todas las evaluaciones'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create a deep copy of existing results
    final Map<String, List<List<int>>> updatedResults = {};
    widget.activity.results.forEach((name, fields) {
      updatedResults[name] = fields
          .map((field) => List<int>.from(field))
          .toList();
    });

    // Add current user's ratings to each member's score lists
    _ratings.forEach((studentName, ratings) {
      // Ensure the student exists in results
      if (!updatedResults.containsKey(studentName)) {
        updatedResults[studentName] = [[], [], [], []];
      }

      // Add this user's rating to each field's peer score list
      for (int i = 0; i < 4; i++) {
        if (ratings[i] != null) {
          updatedResults[studentName]![i].add(ratings[i]!);
        }
      }
    });

    // Update activity results
    final updatedActivity = Activity(
      id: widget.activity.id,
      name: widget.activity.name,
      description: widget.activity.description,
      course: widget.activity.course,
      category: widget.activity.category,
      assessment: widget.activity.assessment,
      results: updatedResults,
    );

    await _activityController.updateActivity(updatedActivity);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluación enviada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.activity.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _membersToRate.length,
              itemBuilder: (context, index) {
                final memberName = _membersToRate[index];
                return _MemberRatingCard(
                  memberName: memberName,
                  ratings: _ratings[memberName]!,
                  onRatingChanged: (criteriaIndex, score) {
                    setState(() {
                      _ratings[memberName]![criteriaIndex] = score;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRatings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Finalizar Evaluación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for rating a single member
class _MemberRatingCard extends StatelessWidget {
  final String memberName;
  final List<int?> ratings;
  final Function(int criteriaIndex, int score) onRatingChanged;

  const _MemberRatingCard({
    required this.memberName,
    required this.ratings,
    required this.onRatingChanged,
  });

  static const List<String> _criteria = [
    'Puntualidad',
    'Contribuciones',
    'Compromiso',
    'Actitud',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              memberName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(_criteria.length, (criteriaIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _criteria[criteriaIndex],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (scoreIndex) {
                      final score = scoreIndex + 2; // Scores from 2 to 5
                      final isSelected = ratings[criteriaIndex] == score;

                      return InkWell(
                        onTap: () => onRatingChanged(criteriaIndex, score),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.blue : Colors.grey[300],
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              score.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
