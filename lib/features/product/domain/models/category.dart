//import 'group.dart';

class Category {
  final String name;
  final bool isRandomSelection;
  final String? id;
  final String? courseID;
  final int groupSize; // New field

  Category({
    required this.courseID,
    required this.name,
    required this.isRandomSelection,
    required this.groupSize, // Add to constructor
    this.id = '0', // Initialize id to '0' by default
  });
}
