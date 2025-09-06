import 'group.dart';

class Category {
  final String name;
  final List<Group> groups;
  final bool isRandomSelection;

  Category({
    required this.name,
    required this.groups,
    required this.isRandomSelection,
  });
}
