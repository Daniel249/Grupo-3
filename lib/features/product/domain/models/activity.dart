class Activity {
  Activity({
    this.id,
    required this.name,
    required this.description,
    required this.course,
  });

  String? id;
  String name;
  String description;
  String course;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json["_id"],
    name: json["name"] ?? "---",
    description: json["description"] ?? "---",
    course: json["course"] ?? "---",
  );

  Map<String, dynamic> toJson() => {
    "_id": id ?? "0",
    "name": name,
    "description": description,
    "course": course,
  };

  Map<String, dynamic> toJsonNoId() => {
    "name": name,
    "description": description,
    "course": course,
  };

  @override
  String toString() {
    return 'User{entry_id: $id, name: $name, description: $description, course: $course}';
  }
}
