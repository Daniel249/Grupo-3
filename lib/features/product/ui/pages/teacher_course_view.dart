//import 'package:f_clean_template/features/product/ui/controller/course_controller.dart';
import 'package:flutter/material.dart';
import '../../domain/models/course.dart';
import '../../domain/models/user.dart';
//import '../../domain/models/activity.dart';
import '../../domain/models/category.dart';
import 'see_categories_page.dart';
//import 'package:get/get.dart';

class TeacherCourseViewPage extends StatefulWidget {
  final Course course;
  final User currentUser;

  const TeacherCourseViewPage({
    super.key,
    required this.course,
    required this.currentUser,
  });

  @override
  State<TeacherCourseViewPage> createState() => _TeacherCourseViewPageState();
}

class _TeacherCourseViewPageState extends State<TeacherCourseViewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.course.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Description'),
            Tab(text: 'Activities'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DescriptionTab(course: widget.course),
          ActivitiesTab(course: widget.course),
          CategoriesTab(course: widget.course),
        ],
      ),
    );
  }
}

class DescriptionTab extends StatefulWidget {
  final Course course;

  const DescriptionTab({super.key, required this.course});

  @override
  State<DescriptionTab> createState() => _DescriptionTabState();
}

class _DescriptionTabState extends State<DescriptionTab> {
  void _showUpdateDescriptionDialog(BuildContext context) {
    final descriptionController = TextEditingController(
      text: widget.course.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Description'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          child: TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter new description',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.course.description = descriptionController.text;

              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final studentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student'),
        content: TextField(
          controller: studentController,
          decoration: const InputDecoration(
            hintText: 'Enter student name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (studentController.text.isNotEmpty) {
                setState(() {
                  widget.course.studentsNames.add(studentController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(widget.course.description),
          const SizedBox(height: 16),
          const Text('Students'),
          const SizedBox(height: 8),
          // Student list in scrollable container
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // List of students (not scrollable itself)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.course.studentsNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(widget.course.studentsNames[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              widget.course.studentsNames.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                  // Add student button follows immediately after list
                  ElevatedButton(
                    onPressed: () => _showAddStudentDialog(context),
                    child: const Text('Add Student'),
                  ),
                ],
              ),
            ),
          ),
          // Bottom buttons stay fixed
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showUpdateDescriptionDialog(context),
                  child: const Text('Update Description'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement delete course
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete Course'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivitiesTab extends StatelessWidget {
  final Course course;

  const ActivitiesTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: course.activities?.length ?? 0,
              itemBuilder: (context, index) {
                final activity = course.activities![index];
                return ListTile(
                  title: Text(activity.name),
                  subtitle: Text(activity.category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // TODO: Implement delete activity
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showAddActivityDialog(context);
            },
            child: const Text('Add Activity'),
          ),
        ],
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Activity Name'),
              ),
              // TODO: Add category dropdown
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement add activity
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class CategoriesTab extends StatelessWidget {
  final Course course;

  const CategoriesTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: course.categories?.length ?? 0,
              itemBuilder: (context, index) {
                final category = course.categories![index];
                return ListTile(
                  title: Text(category.name),
                  subtitle: Text(
                    category.isRandomSelection
                        ? 'Random Selection'
                        : 'Self-Organized',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // TODO: Implement delete category
                    },
                  ),
                  onTap: () => _showCategoryPage(context, category),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddCategoryDialog(context),
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        bool isRandom = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Random Selection'),
                    value: isRandom,
                    onChanged: (value) {
                      setState(() => isRandom = value ?? false);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement add category
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCategoryPage(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryPage(category: category)),
    );
  }
}
