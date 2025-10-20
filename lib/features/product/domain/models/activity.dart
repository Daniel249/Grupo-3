//import 'dart:ffi';

class Activity {
  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.course,
    required this.category,
    required this.results,
    required this.assessment,
  });

  String? id;
  String name;
  String description;
  String course;
  String category;
  bool assessment;
  Map<String, List<int>?> results;

  factory Activity.fromJson(Map<String, dynamic> json) {
    // Parse results from JSON
    Map<String, List<int>?> parsedResults = {};

    if (json["Results"] != null && json["Results"] is Map) {
      final resultsMap = json["Results"] as Map<String, dynamic>;

      resultsMap.forEach((studentName, scoresValue) {
        if (scoresValue == null) {
          parsedResults[studentName] = null;
        } else if (scoresValue is String) {
          // Parse comma-separated string into List<int>
          if (scoresValue.isEmpty) {
            parsedResults[studentName] = [];
          } else {
            parsedResults[studentName] = scoresValue
                .split(',')
                .map((s) => int.tryParse(s.trim()) ?? -1)
                .toList();
          }
        } else if (scoresValue is List) {
          // Already a list, just convert to List<int>
          parsedResults[studentName] = scoresValue
              .map((e) => e is int ? e : int.tryParse(e.toString()) ?? -1)
              .toList();
        }
      });
    }

    return Activity(
      id: json["_id"],
      name: json["Nombre"] ?? "---",
      description: json["Description"] ?? "---",
      course: json["CourseID"] ?? "---",
      category: json["CategoryID"] ?? "---",
      assessment: json["Assessment"] ?? false,
      results: parsedResults,
    );
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
