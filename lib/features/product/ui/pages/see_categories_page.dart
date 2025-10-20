import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';
import '../../domain/models/activity.dart';
import '../controller/group_controller.dart';
import '../controller/activity_controller.dart';

class CategoryPage extends StatefulWidget {
  final Category category;

  const CategoryPage({super.key, required this.category});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final GroupController _groupController = Get.find<GroupController>();
  final ActivityController _activityController = Get.find<ActivityController>();
  List<Group> _filteredGroups = [];
  List<Activity> _categoryActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroups();
    });
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });

    await _groupController.getGroups();
    await _activityController.getActivities(null);

    // Filter groups based on matching categoryId to this category's id
    final filteredGroups = _groupController.groups
        .where((group) => group.categoryId == widget.category.id)
        .toList();

    // Filter activities based on matching category
    final categoryActivities = _activityController.activities
        .where((activity) => activity.category == widget.category.id)
        .toList();

    setState(() {
      _filteredGroups = filteredGroups;
      _categoryActivities = categoryActivities;
      _isLoading = false;
    });
  }

  double _calculateStudentAverage(String studentName) {
    if (_categoryActivities.isEmpty) return 0.0;

    double totalSum = 0.0;
    int activityCount = 0;

    for (var activity in _categoryActivities) {
      // Use the pre-calculated student average from the activity
      final average = activity.studentAverages?[studentName] ?? 0.0;
      if (average > 0.0) {
        totalSum += average;
        activityCount++;
      }
    }

    return activityCount > 0 ? totalSum / activityCount : 0.0;
  }

  double _calculateGroupAverage(Group group) {
    if (group.studentsNames.isEmpty) return 0.0;

    double totalSum = 0.0;
    int studentCount = 0;

    for (var studentName in group.studentsNames) {
      final studentAvg = _calculateStudentAverage(studentName);
      if (studentAvg > 0.0) {
        totalSum += studentAvg;
        studentCount++;
      }
    }

    return studentCount > 0 ? totalSum / studentCount : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.category.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category.isRandomSelection
                  ? 'Random Selection'
                  : 'Self-Organized',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text('Groups', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = _filteredGroups[index];
                        final groupAverage = _calculateGroupAverage(group);

                        return ListTile(
                          title: Text(group.name),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: groupAverage == 0.0
                                  ? Colors.grey
                                  : groupAverage >= 4.0
                                  ? Colors.green
                                  : groupAverage >= 3.0
                                  ? Colors.orange
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              groupAverage == 0.0
                                  ? 'No Score'
                                  : groupAverage.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () => _showGroupStudents(context, group),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupStudents(BuildContext context, Group group) {
    final groupAverage = _calculateGroupAverage(group);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(group.name),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: groupAverage == 0.0
                    ? Colors.grey
                    : groupAverage >= 4.0
                    ? Colors.green
                    : groupAverage >= 3.0
                    ? Colors.orange
                    : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                groupAverage == 0.0
                    ? 'Group Average: No Score'
                    : 'Group Average: ${groupAverage.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: group.studentsNames.length,
            itemBuilder: (context, index) {
              final studentName = group.studentsNames[index];
              final studentAverage = _calculateStudentAverage(studentName);

              return ListTile(
                title: Text(studentName),
                trailing: Text(
                  studentAverage == 0.0
                      ? 'No Score'
                      : studentAverage.toStringAsFixed(2),
                  style: TextStyle(
                    color: studentAverage == 0.0
                        ? Colors.grey
                        : studentAverage >= 4.0
                        ? Colors.green
                        : studentAverage >= 3.0
                        ? Colors.orange
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
