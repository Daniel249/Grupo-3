import '../models/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategories(String? courseId);
  Future<bool> addCategory(Category category);
  Future<bool> updateCategory(Category category);
  Future<bool> deleteCategory(Category category);
}
