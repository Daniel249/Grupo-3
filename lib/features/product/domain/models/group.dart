class Group {
  final String name;
  final List<String> studentsNames;
  final String id;
  final String? categoryId;

  Group({
    required this.name,
    required this.studentsNames,
    required this.id,
    this.categoryId,
  });
}
