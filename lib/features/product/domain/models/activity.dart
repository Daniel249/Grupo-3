//import 'dart:ffi';

import 'dart:convert';

class Activity {
  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.course,
    required this.category,
    required this.results,
    required this.assessment,
    this.studentAverages,
  });

  String? id;
  String name;
  String description;
  String course;
  String category;
  bool assessment;
  // Map of student name to list of 4 fields, each field is a list of peer scores
  Map<String, List<List<int>>> results;
  // Calculated averages for each student
  Map<String, double>? studentAverages;

  factory Activity.fromJson(Map<String, dynamic> json) {
    // Parse results from JSON
    Map<String, List<List<int>>> parsedResults = {};

    if (json["Results"] != null && json["Results"] is Map) {
      final resultsMap = json["Results"] as Map<String, dynamic>;

      resultsMap.forEach((studentName, scoresValue) {
        if (scoresValue == null) {
          parsedResults[studentName] = [[], [], [], []];
        } else if (scoresValue is String) {
          try {
            // Parse JSON string to List<List<int>>
            final decoded = jsonDecode(scoresValue);
            if (decoded is List) {
              parsedResults[studentName] = decoded.map<List<int>>((field) {
                if (field is List) {
                  return field
                      .map(
                        (e) => e is int ? e : int.tryParse(e.toString()) ?? -1,
                      )
                      .toList();
                }
                return <int>[];
              }).toList();
            }
          } catch (e) {
            parsedResults[studentName] = [[], [], [], []];
          }
        } else if (scoresValue is List) {
          parsedResults[studentName] = scoresValue.map<List<int>>((field) {
            if (field is List) {
              return field
                  .map((e) => e is int ? e : int.tryParse(e.toString()) ?? -1)
                  .toList();
            }
            return <int>[];
          }).toList();
        }
      });
    }

    final activity = Activity(
      id: json["_id"],
      name: json["Nombre"] ?? "---",
      description: json["Description"] ?? "---",
      course: json["CourseID"] ?? "---",
      category: json["CategoryID"] ?? "---",
      assessment: json["Assessment"] ?? false,
      results: parsedResults,
    );

    // Calculate student averages
    activity._calculateStudentAverages();

    return activity;
  }

  // Calculate average for each student across all 4 fields
  void _calculateStudentAverages() {
    studentAverages = {};

    results.forEach((studentName, fields) {
      double totalSum = 0.0;
      int totalCount = 0;

      // For each of the 4 fields (punctuality, contributions, commitment, attitude)
      for (var peerScores in fields) {
        if (peerScores.isNotEmpty) {
          // Average all peer scores for this field
          final validScores = peerScores.where((score) => score != -1).toList();
          if (validScores.isNotEmpty) {
            final fieldAvg =
                validScores.reduce((a, b) => a + b) / validScores.length;
            totalSum += fieldAvg;
            totalCount++;
          }
        }
      }

      studentAverages![studentName] = totalCount > 0
          ? totalSum / totalCount
          : 0.0;
    });
  }

  Map<String, dynamic> toJson() => {
    "_id": id ?? "0",
    "Nombre": name,
    "Description": description,
    "CourseID": course,
    "CategoryID": category,
    "Assessment": assessment,
  };

  Map<String, dynamic> toJsonNoId() => {
    "Nombre": name,
    "Description": description,
    "CourseID": course,
    "CategoryID": category,
    "Assessment": assessment,
  };

  @override
  String toString() {
    return 'User{entry_id: $id, name: $name, description: $description, course: $course}';
  }
}
