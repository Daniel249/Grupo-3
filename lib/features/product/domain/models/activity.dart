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
    this.assessName,
    this.isPublic,
    this.time,
    this.already,
  });

  String? id;
  String name;
  String description;
  String course;
  String category;
  bool assessment;
  // Map structure: evaluatorName -> (evaluatedStudentName -> [4 scores for criteria])
  // First key: student giving the scores
  // Nested map: student receiving scores -> list of 4 criteria scores
  Map<String, Map<String, List<int>>> results;
  // Calculated averages for each student
  Map<String, double>? studentAverages;
  // Optional fields for active assessment
  String? assessName;
  bool? isPublic;
  DateTime? time;
  // List of students who have completed the assessment
  List<String>? already;

  factory Activity.fromJson(Map<String, dynamic> json) {
    // Parse results from JSON
    // New structure: Map<evaluatorName, Map<evaluatedStudent, List<int>>>
    Map<String, Map<String, List<int>>> parsedResults = {};

    if (json["Results"] != null && json["Results"] is Map) {
      final resultsMap = json["Results"] as Map<String, dynamic>;

      resultsMap.forEach((evaluatorName, evaluatorScores) {
        if (evaluatorScores == null) {
          parsedResults[evaluatorName] = {};
        } else if (evaluatorScores is String) {
          try {
            // Parse JSON string to Map<String, List<int>>
            final decoded = jsonDecode(evaluatorScores);
            if (decoded is Map) {
              final Map<String, List<int>> peerScores = {};
              decoded.forEach((peerName, scores) {
                if (scores is List) {
                  peerScores[peerName.toString()] = scores
                      .map(
                        (e) => e is int ? e : int.tryParse(e.toString()) ?? -1,
                      )
                      .toList();
                } else if (scores is String) {
                  try {
                    final decodedScores = jsonDecode(scores);
                    if (decodedScores is List) {
                      peerScores[peerName.toString()] = decodedScores
                          .map(
                            (e) =>
                                e is int ? e : int.tryParse(e.toString()) ?? -1,
                          )
                          .toList();
                    }
                  } catch (e) {
                    peerScores[peerName.toString()] = [];
                  }
                }
              });
              parsedResults[evaluatorName] = peerScores;
            }
          } catch (e) {
            parsedResults[evaluatorName] = {};
          }
        } else if (evaluatorScores is Map) {
          final Map<String, List<int>> peerScores = {};
          evaluatorScores.forEach((peerName, scores) {
            if (scores is List) {
              peerScores[peerName.toString()] = scores
                  .map((e) => e is int ? e : int.tryParse(e.toString()) ?? -1)
                  .toList();
            }
          });
          parsedResults[evaluatorName] = peerScores;
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
      assessName: json["AssessName"]?.toString(),
      isPublic: json["IsPublic"] as bool?,
      time: json["Time"] != null ? _parseDateTime(json["Time"]) : null,
      already: _parseAlreadyList(json["Already"]),
    );

    // Calculate student averages
    activity._calculateStudentAverages();

    return activity;
  }

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic timeValue) {
    if (timeValue == null) return null;

    try {
      if (timeValue is String) {
        return DateTime.parse(timeValue);
      } else if (timeValue is int) {
        // Unix timestamp in milliseconds
        return DateTime.fromMillisecondsSinceEpoch(timeValue);
      } else if (timeValue is DateTime) {
        return timeValue;
      }
    } catch (e) {
      // Return null if parsing fails
      return null;
    }

    return null;
  }

  // Helper method to parse Already list from JSON
  static List<String>? _parseAlreadyList(dynamic alreadyValue) {
    if (alreadyValue == null) return null;

    try {
      if (alreadyValue is String) {
        // Parse JSON string to List
        final decoded = jsonDecode(alreadyValue);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } else if (alreadyValue is List) {
        return alreadyValue.map((e) => e.toString()).toList();
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  // Calculate average for each student across all 4 fields
  // New logic: gather all scores given TO each student by all evaluators
  void _calculateStudentAverages() {
    studentAverages = {};

    // First, identify all students who were evaluated
    Set<String> allEvaluatedStudents = {};
    results.forEach((evaluator, peerScores) {
      allEvaluatedStudents.addAll(peerScores.keys);
    });

    // For each evaluated student, gather all scores given to them
    for (var studentName in allEvaluatedStudents) {
      // Collect all scores given TO this student across all 4 criteria
      List<List<int>> scoresPerCriteria = [[], [], [], []]; // 4 criteria

      // Look through all evaluators
      results.forEach((evaluator, peerScores) {
        if (peerScores.containsKey(studentName)) {
          final scores = peerScores[studentName]!;
          // scores is a list of 4 integers (one per criteria)
          for (int i = 0; i < scores.length && i < 4; i++) {
            if (scores[i] != -1) {
              scoresPerCriteria[i].add(scores[i]);
            }
          }
        }
      });

      // Calculate average across all criteria
      double totalSum = 0.0;
      int totalCount = 0;

      for (var criteriaScores in scoresPerCriteria) {
        if (criteriaScores.isNotEmpty) {
          final criteriaAvg =
              criteriaScores.reduce((a, b) => a + b) / criteriaScores.length;
          totalSum += criteriaAvg;
          totalCount++;
        }
      }

      studentAverages![studentName] = totalCount > 0
          ? totalSum / totalCount
          : 0.0;
    }
  }

  Map<String, dynamic> toJson() => {
    "_id": id ?? "0",
    "Nombre": name,
    "Description": description,
    "CourseID": course,
    "CategoryID": category,
    "Assessment": assessment,
    if (assessName != null) "AssessName": assessName,
    if (isPublic != null) "IsPublic": isPublic,
    if (time != null) "Time": time!.toUtc().toIso8601String(),
    if (already != null) "Already": jsonEncode(already),
  };

  Map<String, dynamic> toJsonNoId() => {
    "Nombre": name,
    "Description": description,
    "CourseID": course,
    "CategoryID": category,
    "Assessment": assessment,
    if (assessName != null) "AssessName": assessName,
    if (isPublic != null) "IsPublic": isPublic,
    if (time != null) "Time": time!.toUtc().toIso8601String(),
    if (already != null) "Already": jsonEncode(already),
  };

  @override
  String toString() {
    return 'User{entry_id: $id, name: $name, description: $description, course: $course}';
  }
}
