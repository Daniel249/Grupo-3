import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';
import '../controller/group_controller.dart';
import 'group_grades_page.dart';

class ActivityGroupsPage extends StatefulWidget {
  final Activity activity;
  final Category category;

  const ActivityGroupsPage({
    super.key,
    required this.activity,
    required this.category,
  });

  @override
  State<ActivityGroupsPage> createState() => _ActivityGroupsPageState();
}

class _ActivityGroupsPageState extends State<ActivityGroupsPage> {
  final GroupController _groupController = Get.find<GroupController>();

  List<Group> get _categoryGroups => _groupController.groups
      .where((group) => group.categoryId == widget.category.id)
      .toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupController.getGroups();
    });
  }

  double _calculateGroupAverage(Group group) {
    if (group.studentsNames.isEmpty) return 0.0;

    double totalSum = 0.0;
    int studentCount = 0;

    for (String studentName in group.studentsNames) {
      final grades = widget.activity.results[studentName];
      if (grades != null && grades.isNotEmpty) {
        // Calculate average for this student
        double studentSum = 0.0;
        int gradeCount = 0;
        for (int? grade in grades) {
          if (grade != null && grade != -1) {
            studentSum += grade;
            gradeCount++;
          }
        }
        if (gradeCount > 0) {
          totalSum += studentSum / gradeCount;
          studentCount++;
        }
      }
    }

    return studentCount > 0 ? totalSum / studentCount : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.activity.name} - Groups')),
      body: Obx(() {
        if (_categoryGroups.isEmpty) {
          return const Center(child: Text('No groups in this category'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _categoryGroups.length,
          itemBuilder: (context, index) {
            final group = _categoryGroups[index];
            final average = _calculateGroupAverage(group);

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                title: Text(
                  group.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${group.studentsNames.length} students'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: _getAverageColor(average),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Avg: ${average.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupGradesPage(
                        activity: widget.activity,
                        group: group,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }

  Color _getAverageColor(double average) {
    if (average >= 4.0) return Colors.green;
    if (average >= 3.0) return Colors.orange;
    return Colors.red;
  }
}
