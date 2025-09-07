import '../models/category.dart';
import '../repositories/i_category_repository.dart';

class CategoryUseCase {
  final ICategoryRepository repository;

  CategoryUseCase(this.repository);

  Future<List<Category>> getCategories() async => repository.getCategories();
  Future<bool> addCategory(Category category) async =>
      repository.addCategory(category);
  Future<bool> updateCategory(Category category) async =>
      repository.updateCategory(category);
  Future<bool> deleteCategory(Category category) async =>
      repository.deleteCategory(category);
}
