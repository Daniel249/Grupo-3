//import 'package:f_clean_template/features/product/ui/controller/course_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/models/user.dart';
import '../../domain/models/category.dart';
import 'see_categories_page.dart';
import 'package:f_clean_template/features/product/ui/controller/course_controller.dart';
import '../../domain/models/activity.dart';
import '../controller/category_controller.dart';

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
  final CourseController _courseController = Get.find<CourseController>();

  void _showUpdateDescriptionDialog(BuildContext context) {
    final descriptionController = TextEditingController(
      text: widget.course.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Description'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
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
              final updatedCourse = Course(
                id: widget.course.id,
                name: widget.course.name,
                description: descriptionController.text,
                studentsNames: widget.course.studentsNames,
                teacher: widget.course.teacher,
                activities: widget.course.activities,
                categories: widget.course.categories,
              );
              _courseController.updateCourse(updatedCourse);
              setState(() {
                widget.course.description = descriptionController.text;
              });
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
                final List<String> updatedStudents = [
                  ...widget.course.studentsNames,
                ];
                updatedStudents.add(studentController.text);

                final updatedCourse = Course(
                  id: widget.course.id,
                  name: widget.course.name,
                  description: widget.course.description,
                  studentsNames: updatedStudents,
                  teacher: widget.course.teacher,
                  activities: widget.course.activities,
                  categories: widget.course.categories,
                );
                _courseController.updateCourse(updatedCourse);
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
                            final List<String> updatedStudents = [
                              ...widget.course.studentsNames,
                            ];
                            updatedStudents.removeAt(index);

                            final updatedCourse = Course(
                              id: widget.course.id,
                              name: widget.course.name,
                              description: widget.course.description,
                              studentsNames: updatedStudents,
                              teacher: widget.course.teacher,
                              activities: widget.course.activities,
                              categories: widget.course.categories,
                            );
                            _courseController.updateCourse(updatedCourse);
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
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Course'),
                        content: const Text(
                          'Are you sure you want to delete this course?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed ?? false) {
                      _courseController.deleteCourse(widget.course);
                      Navigator.pop(context); // Return to courses list
                    }
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

class ActivitiesTab extends StatefulWidget {
  final Course course;

  const ActivitiesTab({super.key, required this.course});

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  final CourseController _courseController = Get.find<CourseController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.course.activities?.length ?? 0,
              itemBuilder: (context, index) {
                final activity = widget.course.activities![index];
                return ListTile(
                  title: Text(activity.name),
                  subtitle: Text(activity.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      final List<Activity> updatedActivities = [
                        ...widget.course.activities ?? [],
                      ];
                      updatedActivities.removeAt(index);

                      final updatedCourse = Course(
                        id: widget.course.id,
                        name: widget.course.name,
                        description: widget.course.description,
                        studentsNames: widget.course.studentsNames,
                        teacher: widget.course.teacher,
                        activities: updatedActivities,
                        categories: widget.course.categories,
                      );
                      _courseController.updateCourse(updatedCourse);
                      setState(() {
                        widget.course.activities?.removeAt(index);
                      });
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

class CategoriesTab extends StatefulWidget {
  final Course course;

  const CategoriesTab({super.key, required this.course});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  //final CourseController _courseController = Get.find<CourseController>();
  final CategoryController _categoryController = Get.find<CategoryController>();

  List<Category> get _courseCategories => _categoryController.categories
      .where((category) => category.courseID == widget.course.id)
      .toList();

  @override
  void initState() {
    super.initState();
    _categoryController.getCategories(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: _courseCategories.length,
                itemBuilder: (context, index) {
                  final category = _courseCategories[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text(
                      category.isRandomSelection
                          ? 'Random Selection'
                          : 'Self-Organized',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _categoryController.deleteCategory(category);
                        await _categoryController.getCategories(
                          widget.course.id,
                        );
                        setState(() {});
                      },
                    ),
                    onTap: () => _showCategoryPage(context, category),
                  );
                },
              ),
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

  void _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final groupSizeController = TextEditingController();
    bool isRandom = false;
    final result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                  TextField(
                    controller: groupSizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Group Size'),
                  ),
                  CheckboxListTile(
                    title: const Text('Random Selection'),
                    value: isRandom,
                    onChanged: (value) {
                      setStateDialog(() => isRandom = value ?? false);
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
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        groupSizeController.text.isNotEmpty) {
                      final groupSize =
                          int.tryParse(groupSizeController.text) ?? 1;

                      final courseId = widget.course.id;
                      await _categoryController.addCategory(
                        nameController.text,
                        isRandom,
                        courseId,
                        groupSize, // Pass group size as second to last
                        [], // Empty groups list as last parameter
                      );
                      Navigator.pop(
                        context,
                        true,
                      ); // return true to indicate added
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == true) {
      await _categoryController.getCategories(widget.course.id);
      setState(() {}); // Rebuild main tab
    }
  }

  void _showCategoryPage(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryPage(category: category)),
    );
  }
}
