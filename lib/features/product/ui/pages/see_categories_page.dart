import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';
import '../controller/group_controller.dart';

class CategoryPage extends StatefulWidget {
  final Category category;

  const CategoryPage({super.key, required this.category});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final GroupController _groupController = Get.find<GroupController>();
  List<Group> _filteredGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });

    await _groupController.getGroups();

    // Filter groups based on matching categoryId to this category's id
    final filteredGroups = _groupController.groups
        .where((group) => group.categoryId == widget.category.id)
        .toList();

    setState(() {
      _filteredGroups = filteredGroups;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.category.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category.isRandomSelection
                  ? 'Random Selection'
                  : 'Self-Organized',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text('Groups', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = _filteredGroups[index];
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
            itemCount: group.studentsNames.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(group.studentsNames[index]));
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
