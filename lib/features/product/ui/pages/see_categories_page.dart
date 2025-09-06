import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';

class CategoryPage extends StatelessWidget {
  final Category category;

  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(category.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.isRandomSelection
                  ? 'Random Selection'
                  : 'Self-Organized',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text('Groups', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: ListView.builder(
                itemCount: category.groups.length,
                itemBuilder: (context, index) {
                  final group = category.groups[index];
                  return ListTile(
                    title: Text(group.name),
                    onTap: () => _showGroupStudents(context, group),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupStudents(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group.name),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: group.students.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(group.students[index]));
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
