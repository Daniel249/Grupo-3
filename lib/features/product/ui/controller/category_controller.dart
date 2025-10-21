import 'package:get/get.dart';
import 'dart:math';
import '../../domain/models/category.dart';
import '../../domain/use_case/category_usecase.dart';
import '../../domain/models/group.dart';
import 'group_controller.dart';
import 'course_controller.dart';
import '../../domain/usecases/group_use_case.dart';

class CategoryController extends GetxController {
  final RxList<Category> _categories = <Category>[].obs;
  final CategoryUseCase categoryUseCase = Get.find();
  final RxBool isLoading = false.obs;
  List<Category> get categories => _categories;

  getCategories(String? courseId) async {
    isLoading.value = true;
    _categories.value = await categoryUseCase.getCategories(courseId);
    isLoading.value = false;
  }

  Future<void> addCategory(
    String name,
    bool isRandomSelection,
    String courseID,
    int groupSize,
    List<String> groups,
  ) async {
    // First add the category
    await categoryUseCase.addCategory(
      name,
      isRandomSelection,
      courseID,
      groupSize,
      groups,
    );

    // Refresh categories to get the new category with ID
    await getCategories(courseID);

    // If random selection, create groups and assign students
    if (isRandomSelection) {
      final courseController = Get.find<CourseController>();
      final groupController = Get.find<GroupController>();

      // Find the course
      final course = courseController.courses.firstWhereOrNull(
        (c) => c.id == courseID,
      );

      if (course != null && course.studentsNames.isNotEmpty) {
        // Find the newly created category
        final category = _categories.firstWhereOrNull(
          (cat) => cat.courseID == courseID && cat.name == name,
        );

        if (category != null && category.id != null) {
          // Calculate number of groups needed
          final numStudents = course.studentsNames.length;
          final numGroups = (numStudents / groupSize).ceil();

          // Shuffle students for random assignment
          final shuffledStudents = List<String>.from(course.studentsNames);
          shuffledStudents.shuffle(Random());

          // Create groups and assign students
          for (int i = 0; i < numGroups; i++) {
            final groupName = 'Group ${i + 1}';
            final startIndex = i * groupSize;
            final endIndex = min(startIndex + groupSize, numStudents);
            final groupStudents = shuffledStudents.sublist(
              startIndex,
              endIndex,
            );

            final newGroup = Group(
              id: '0',
              name: groupName,
              studentsNames: groupStudents,
              categoryId: category.id!,
            );

            await groupController.addGroup(newGroup);
          }
        }
      }
    }

    await getCategories(courseID);
  }

  Future<void> updateCategory(Category category) async {
    await categoryUseCase.updateCategory(category);
    await getCategories(category.courseID);
  }

  Future<void> deleteCategory(Category category) async {
    // First, delete all groups that belong to this category
    if (category.id != null) {
      final groupController = Get.find<GroupController>();
      final groupUseCase = Get.find<GroupUseCase>();

      // Get all groups
      await groupController.getGroups();

      // Find groups with matching categoryId (create a copy of the list)
      final groupsToDelete = groupController.groups
          .where((group) => group.categoryId == category.id)
          .toList();

      print(
        'Deleting category ${category.id}, found ${groupsToDelete.length} groups to delete',
      );

      // Delete each group using the use case directly to avoid multiple refreshes
      for (final group in groupsToDelete) {
        print(
          'Deleting group ${group.id} (${group.name}) with categoryId ${group.categoryId}',
        );
        // Use the use case directly to avoid calling getGroups() after each deletion
        await groupUseCase.deleteGroup(group);
      }

      // Refresh groups list once after all deletions
      await groupController.getGroups();
    }

    // Then delete the category
    await categoryUseCase.deleteCategory(category);
    await getCategories(category.courseID);
  }
}
