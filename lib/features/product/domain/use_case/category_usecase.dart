import 'dart:math';
import '../models/category.dart';
import '../repositories/i_category_repository.dart';
import '../models/group.dart';

class CategoryUseCase {
  final ICategoryRepository repository;

  CategoryUseCase(this.repository);

  Future<List<Category>> getCategories(String? courseId) async =>
      await repository.getCategories(courseId);

  Future<void> addCategory(
    String name,
    bool isRandomSelection,
    String courseID,
    int groupSize,
    List<String> groups,
  ) async => await repository.addCategory(
    Category(
      name: name,
      isRandomSelection: isRandomSelection,
      courseID: courseID,
      groupSize: groupSize,
    ),
  );

  Future<bool> updateCategory(Category category) async =>
      await repository.updateCategory(category);

  Future<bool> deleteCategory(Category category) async =>
      await repository.deleteCategory(category);
}
