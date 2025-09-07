import 'dart:math';
import '../models/category.dart';
import '../repositories/i_category_repository.dart';
import '../models/group.dart';

class CategoryUseCase {
  final ICategoryRepository repository;

  CategoryUseCase(this.repository);

  Future<List<Category>> getCategories() async =>
      await repository.getCategories();

  Future<void> addCategory(
    String name,
    bool isRandomSelection,
    int courseID,
    int groupSize,
    List<Group> groups,
  ) async => await repository.addCategory(
    Category(
      id: Random().nextInt(10000),
      name: name,
      isRandomSelection: isRandomSelection,
      courseID: courseID,
      groupSize: groupSize,
      groups: groups,
    ),
  );

  Future<bool> updateCategory(Category category) async =>
      await repository.updateCategory(category);

  Future<bool> deleteCategory(Category category) async =>
      await repository.deleteCategory(category);
}
