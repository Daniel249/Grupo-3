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

  double _calculateFieldAverage(List<int> peerScores) {
    if (peerScores.isEmpty) return 0.0;

    final validScores = peerScores.where((score) => score != -1).toList();
    if (validScores.isEmpty) return 0.0;

    return validScores.reduce((a, b) => a + b) / validScores.length;
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
                  final fields =
                      activity.results[studentName] ?? [[], [], [], []];

                  // Calculate average for each field
                  final field1Avg = _calculateFieldAverage(
                    fields.isNotEmpty ? fields[0] : [],
                  );
                  final field2Avg = _calculateFieldAverage(
                    fields.length > 1 ? fields[1] : [],
                  );
                  final field3Avg = _calculateFieldAverage(
                    fields.length > 2 ? fields[2] : [],
                  );
                  final field4Avg = _calculateFieldAverage(
                    fields.length > 3 ? fields[3] : [],
                  );

                  // Use pre-calculated student average
                  final average = activity.studentAverages?[studentName] ?? 0.0;

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          studentName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Text(
                          field1Avg == 0.0 ? '-' : field1Avg.toStringAsFixed(1),
                        ),
                      ),
                      DataCell(
                        Text(
                          field2Avg == 0.0 ? '-' : field2Avg.toStringAsFixed(1),
                        ),
                      ),
                      DataCell(
                        Text(
                          field3Avg == 0.0 ? '-' : field3Avg.toStringAsFixed(1),
                        ),
                      ),
                      DataCell(
                        Text(
                          field4Avg == 0.0 ? '-' : field4Avg.toStringAsFixed(1),
                        ),
                      ),
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
