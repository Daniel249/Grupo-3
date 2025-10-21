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
        // Active means: has assessment, time hasn't expired, and student hasn't completed it
        final hasActiveAssessment =
            category != null &&
            activities.any((activity) {
              if (activity.category != category.id || !activity.assessment) {
                return false;
              }

              // Check if time hasn't expired
              if (activity.time != null &&
                  DateTime.now().isAfter(activity.time!)) {
                return false;
              }

              // Check if student hasn't completed it (student's name not in results)
              if (activity.results.containsKey(widget.currentUser.name)) {
                return false;
              }

              return true;
            });

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

  String _calculateTimeLeft(DateTime? assessmentTime) {
    if (assessmentTime == null) return 'N/A';

    final now = DateTime.now().toUtc();
    final assessmentUtc = assessmentTime.toUtc();
    final difference = assessmentUtc.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
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
                                      'Assessment',
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
                                  DataColumn(
                                    label: Text(
                                      'Time Left',
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

                                  // Determine if scores should be hidden
                                  final isPublic = activity.isPublic ?? true;

                                  // Check if current user has completed the assessment
                                  // Inferred from presence in results map
                                  final hasCompleted = activity.results
                                      .containsKey(widget.currentUser.name);

                                  final timeLeft = hasCompleted
                                      ? 'Completed'
                                      : _calculateTimeLeft(activity.time);

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
                                        Text(activity.assessName ?? 'N/A'),
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
                                          !isPublic
                                              ? 'Hidden'
                                              : myAverage == 0.0
                                              ? 'No Score'
                                              : myAverage.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: !isPublic
                                                ? Colors.grey
                                                : myAverage == 0.0
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
                                          !isPublic
                                              ? 'Hidden'
                                              : groupAverage == 0.0
                                              ? 'No Score'
                                              : groupAverage.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: !isPublic
                                                ? Colors.grey
                                                : groupAverage == 0.0
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
                                      DataCell(
                                        Text(
                                          timeLeft,
                                          style: TextStyle(
                                            color: timeLeft == 'Completed'
                                                ? Colors.green
                                                : timeLeft == 'Expired'
                                                ? Colors.red
                                                : Colors.blue,
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

                  // Check if group size is valid (at least 1 member)
                  if (selectedCategory!.groupSize < 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El tamaño del grupo debe ser al menos 1',
                        ),
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

              // Filter out groups where user already is a member OR groups that are full
              final availableGroups = courseGroups.where((group) {
                if (group.studentsNames.contains(currentUser.name)) {
                  return false; // User is already a member
                }

                // Check if group is full
                final category = categories.firstWhereOrNull(
                  (cat) => cat.id == group.categoryId,
                );
                if (category != null &&
                    group.studentsNames.length >= category.groupSize) {
                  return false; // Group is full
                }

                return true;
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
                  final category = data['category'] as Category?;
                  final displayName = data['displayName'] as String;

                  final groupCapacity = category?.groupSize ?? 0;
                  final currentSize = group.studentsNames.length;
                  final isFull = currentSize >= groupCapacity;

                  return ListTile(
                    title: Text(displayName),
                    subtitle: Text(
                      isFull
                          ? '$currentSize/$groupCapacity miembros (Full)'
                          : '$currentSize/$groupCapacity miembros',
                      style: TextStyle(color: isFull ? Colors.red : null),
                    ),
                    trailing: isFull
                        ? Icon(Icons.block, color: Colors.red)
                        : null,
                    onTap: isFull
                        ? null
                        : () async {
                            final joined = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Unirse a $displayName'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Capacidad: $currentSize/$groupCapacity',
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Integrantes:'),
                                    ...group.studentsNames.map(
                                      (s) => Text('• $s'),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Double-check group capacity before adding
                                      if (group.studentsNames.length >=
                                          groupCapacity) {
                                        Navigator.pop(context, false);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'El grupo está lleno',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      // Add user to the group
                                      if (!group.studentsNames.contains(
                                        currentUser.name,
                                      )) {
                                        group.studentsNames.add(
                                          currentUser.name,
                                        );
                                        await _groupController.updateGroup(
                                          group,
                                        );
                                      }
                                      Navigator.pop(
                                        context,
                                        true,
                                      ); // Close dialog
                                    },
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                            if (joined == true) {
                              Navigator.pop(
                                context,
                              ); // Return to previous screen
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

  bool get _isExpired {
    if (widget.activity.time == null) return false;
    final now = DateTime.now().toUtc();
    final assessmentUtc = widget.activity.time!.toUtc();
    return now.isAfter(assessmentUtc);
  }

  bool get _hasCompleted {
    // Inferred from presence in results map
    return widget.activity.results.containsKey(widget.currentUser.name);
  }

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
    // New structure: Map<evaluatorName, Map<evaluatedStudent, List<int>>>
    final Map<String, Map<String, List<int>>> updatedResults = {};
    widget.activity.results.forEach((evaluator, peerScores) {
      final Map<String, List<int>> copiedPeerScores = {};
      peerScores.forEach((peer, scores) {
        copiedPeerScores[peer] = List<int>.from(scores);
      });
      updatedResults[evaluator] = copiedPeerScores;
    });

    // Add current user's ratings as an evaluator
    final Map<String, List<int>> currentUserScores = {};
    _ratings.forEach((studentName, ratings) {
      // Store all 4 criteria scores for this peer
      final List<int> scoresForPeer = [];
      for (int i = 0; i < 4; i++) {
        scoresForPeer.add(ratings[i] ?? -1);
      }
      currentUserScores[studentName] = scoresForPeer;
    });

    updatedResults[widget.currentUser.name] = currentUserScores;

    // Update activity results
    final updatedActivity = Activity(
      id: widget.activity.id,
      name: widget.activity.name,
      description: widget.activity.description,
      course: widget.activity.course,
      category: widget.activity.category,
      assessment: widget.activity.assessment,
      results: updatedResults,
      assessName: widget.activity.assessName,
      isPublic: widget.activity.isPublic,
      time: widget.activity.time,
      already: widget.activity.already,
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
    // Check if user has already completed the assessment
    if (_hasCompleted) {
      // Get the scores the current user gave to their peers
      final userResults = widget.activity.results[widget.currentUser.name];
      final criteriaNames = [
        'Punctuality',
        'Contributions',
        'Commitment',
        'Attitude',
      ];

      // Calculate average for each criterion across all peers the user evaluated
      List<double> criteriaAverages = [];
      if (userResults != null) {
        // For each criterion (0-3)
        for (int criterionIndex = 0; criterionIndex < 4; criterionIndex++) {
          List<int> scoresForCriterion = [];
          // Collect scores for this criterion from all peers
          userResults.forEach((peerName, scores) {
            if (scores.length > criterionIndex &&
                scores[criterionIndex] != -1) {
              scoresForCriterion.add(scores[criterionIndex]);
            }
          });

          final avg = scoresForCriterion.isNotEmpty
              ? scoresForCriterion.reduce((a, b) => a + b) /
                    scoresForCriterion.length
              : 0.0;
          criteriaAverages.add(avg);
        }
      }

      final overallAverage = criteriaAverages.isNotEmpty
          ? criteriaAverages.reduce((a, b) => a + b) / criteriaAverages.length
          : 0.0;

      return Scaffold(
        appBar: AppBar(title: Text(widget.activity.name)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle, size: 60, color: Colors.green.shade400),
              const SizedBox(height: 12),
              Text(
                'Assessment Completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You have already submitted your evaluation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        'Your Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DataTable(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Criteria',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Average',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: [
                          ...List.generate(criteriaNames.length, (index) {
                            final avg = index < criteriaAverages.length
                                ? criteriaAverages[index]
                                : 0.0;
                            return DataRow(
                              cells: [
                                DataCell(Text(criteriaNames[index])),
                                DataCell(
                                  Text(
                                    avg.toStringAsFixed(2),
                                    style: TextStyle(
                                      color: avg >= 4.0
                                          ? Colors.green
                                          : avg >= 3.0
                                          ? Colors.orange
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          DataRow(
                            cells: [
                              const DataCell(
                                Text(
                                  'Overall Average',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                Text(
                                  overallAverage.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: overallAverage >= 4.0
                                        ? Colors.green
                                        : overallAverage >= 3.0
                                        ? Colors.orange
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if assessment has expired
    if (_isExpired) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.activity.name)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_filled,
                  size: 100,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Expired Assessment',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This assessment has expired and is no longer available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Normal assessment screen
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
