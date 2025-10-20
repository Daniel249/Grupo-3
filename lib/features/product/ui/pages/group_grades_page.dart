import 'package:flutter/material.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/group.dart';

class GroupGradesPage extends StatelessWidget {
  final Activity activity;
  final Group group;

  const GroupGradesPage({
    super.key,
    required this.activity,
    required this.group,
  });

  double _calculateStudentAverage(List<int?> grades) {
    if (grades.isEmpty) return 0.0;

    double sum = 0.0;
    int count = 0;

    for (int? grade in grades) {
      if (grade != null && grade != -1) {
        sum += grade;
        count++;
      }
    }

    return count > 0 ? sum / count : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${group.name} - Grades')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              activity.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.blue.shade100,
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Student',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Punctuality',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Contributions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Commitment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Attitude',
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
                rows: group.studentsNames.map((studentName) {
                  final grades = activity.results[studentName] ?? [];

                  // Ensure we have 4 grades (pad with null if needed)
                  final List<int?> paddedGrades = List<int?>.filled(4, null);
                  for (int i = 0; i < grades.length && i < 4; i++) {
                    paddedGrades[i] = grades[i];
                  }

                  final average = _calculateStudentAverage(paddedGrades);

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          studentName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(Text(paddedGrades[0]?.toString() ?? '-')),
                      DataCell(Text(paddedGrades[1]?.toString() ?? '-')),
                      DataCell(Text(paddedGrades[2]?.toString() ?? '-')),
                      DataCell(Text(paddedGrades[3]?.toString() ?? '-')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: _getAverageColor(average),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            average == 0.0
                                ? 'No Score'
                                : average.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAverageColor(double average) {
    if (average >= 4.0) return Colors.green;
    if (average >= 3.0) return Colors.orange;
    return Colors.red;
  }
}
