import 'group.dart';

class Category {
  final String name;
  final List<Group> groups;
  final bool isRandomSelection;
  final int? id;
  final int? courseID;
  final int groupSize; // New field

  Category({
    required this.id,
    required this.courseID,
    required this.name,
    required this.groups,
    required this.isRandomSelection,
    required this.groupSize, // Add to constructor
  });
}
