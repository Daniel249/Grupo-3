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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupController.getGroups();
    });
  }

  double _calculateGroupAverage(Group group) {
    if (group.studentsNames.isEmpty) return 0.0;

    // Use pre-calculated studentAverages from activity
    if (widget.activity.studentAverages == null) return 0.0;

    double totalSum = 0.0;
    int studentCount = 0;

    for (String studentName in group.studentsNames) {
      final studentAvg = widget.activity.studentAverages?[studentName];
      if (studentAvg != null && studentAvg > 0.0) {
        totalSum += studentAvg;
        studentCount++;
      }
    }

    return studentCount > 0 ? totalSum / studentCount : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.activity.name} - Groups')),
      body: Obx(() {
        // Access the observable directly to make Obx track it
        final allGroups = _groupController.groups;
        final categoryGroups = allGroups
            .where((group) => group.categoryId == widget.category.id)
            .toList();

        if (categoryGroups.isEmpty) {
          return const Center(child: Text('No groups in this category'));
        }

        // Calculate overall average using the filtered groups
        double totalSum = 0.0;
        int groupCount = 0;

        for (var group in categoryGroups) {
          final groupAverage = _calculateGroupAverage(group);
          if (groupAverage > 0.0) {
            totalSum += groupAverage;
            groupCount++;
          }
        }

        final overallAverage = groupCount > 0 ? totalSum / groupCount : 0.0;

        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getAverageColor(overallAverage),
                    _getAverageColor(overallAverage).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Average',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    overallAverage == 0.0
                        ? 'No Score'
                        : overallAverage.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${categoryGroups.length} ${categoryGroups.length == 1 ? 'Group' : 'Groups'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: categoryGroups.length,
                itemBuilder: (context, index) {
                  final group = categoryGroups[index];
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
                          average == 0.0
                              ? 'No Score'
                              : 'Avg: ${average.toStringAsFixed(1)}',
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
              ),
            ),
          ],
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
