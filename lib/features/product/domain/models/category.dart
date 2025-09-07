import 'group.dart';

class Category {
  final String name;
  final List<Group> groups;
  final bool isRandomSelection;
  final int? id;
  final int? courseID;

  Category({
    this.id,
    this.courseID,
    required this.name,
    required this.groups,
    required this.isRandomSelection,
  });
}
