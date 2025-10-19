import '../../domain/models/category.dart';

abstract class ICategorySource {
  Future<List<Category>> getCategories(String? courseId);
  Future<bool> addCategory(Category category);
  Future<bool> updateCategory(Category category);
  Future<bool> deleteCategory(Category category);
}
