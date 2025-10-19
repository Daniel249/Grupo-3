//import 'package:f_clean_template/features/product/ui/controller/course_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/models/user.dart';
import '../../domain/models/category.dart';
import '../../domain/models/activity.dart';
import 'see_categories_page.dart';
import 'activity_groups_page.dart';
import 'package:f_clean_template/features/product/ui/controller/course_controller.dart';
import '../controller/category_controller.dart';
import '../controller/activity_controller.dart';

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
            onPressed: () async {
              // Modify widget.course directly
              widget.course.description = descriptionController.text;

              await _courseController.updateCourse(widget.course);
              await _courseController.getCourses();

              setState(() {}); // Just rebuild to show updated data

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
            onPressed: () async {
              if (studentController.text.isNotEmpty) {
                // Modify widget.course directly
                widget.course.studentsNames.add(studentController.text);

                await _courseController.updateCourse(widget.course);
                await _courseController.getCourses();

                setState(() {}); // Just rebuild to show updated data

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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.course.studentsNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(widget.course.studentsNames[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Modify widget.course directly
                            widget.course.studentsNames.removeAt(index);

                            await _courseController.updateCourse(widget.course);
                            await _courseController.getCourses();

                            setState(
                              () {},
                            ); // Just rebuild to show updated data
                          },
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddStudentDialog(context),
                    child: const Text('Add Student'),
                  ),
                ],
              ),
            ),
          ),
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
                      await _courseController.deleteCourse(widget.course);
                      Navigator.pop(context);
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
  final ActivityController _activityController = Get.find<ActivityController>();
  final CategoryController _categoryController = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activityController.getActivities(widget.course.id);
      _categoryController.getCategories(widget.course.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        final courseActivities = _activityController.activities
            .where((activity) => activity.course == widget.course.id)
            .toList();

        if (_activityController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (courseActivities.isEmpty) {
          return const Center(child: Text('No activities yet'));
        }

        return ListView.builder(
          itemCount: courseActivities.length,
          itemBuilder: (context, index) {
            final activity = courseActivities[index];
            final category = _categoryController.categories.firstWhere(
              (cat) => cat.id == activity.category,
              orElse: () => Category(
                id: null,
                courseID: '',
                name: 'Unknown',
                isRandomSelection: false,
                groupSize: 0,
              ),
            );
            return ListTile(
              title: Text(
                '${activity.name} for ${category.name} category',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(activity.description),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _activityController.deleteActivity(activity);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityGroupsPage(
                      activity: activity,
                      category: category,
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
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
  final ActivityController _activityController = Get.find<ActivityController>();

  List<Category> get _courseCategories => _categoryController.categories
      .where((category) => category.courseID == widget.course.id)
      .toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _categoryController.getCategories(widget.course.id);
      _activityController.getActivities(widget.course.id);
    });
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Add Activity',
                          onPressed: () {
                            _showAddActivityDialog(context, category);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete Category',
                          onPressed: () async {
                            await _categoryController.deleteCategory(category);
                            await _categoryController.getCategories(
                              widget.course.id,
                            );
                            setState(() {});
                          },
                        ),
                      ],
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

  void _showAddActivityDialog(BuildContext context, Category category) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Activity to ${category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Activity Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
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
                  descriptionController.text.isNotEmpty) {
                final newActivity = Activity(
                  id: null,
                  name: nameController.text,
                  description: descriptionController.text,
                  course: widget.course.id,
                  category: category.id!,
                  results: {},
                );

                await _activityController.addActivity(newActivity);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCategoryPage(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryPage(category: category)),
    );
  }
}
