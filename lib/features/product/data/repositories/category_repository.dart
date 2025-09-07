import '../../domain/models/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../datasources/i_category_source.dart';

class CategoryRepository implements ICategoryRepository {
  final ICategorySource remoteCategorySource;

  CategoryRepository(this.remoteCategorySource);

  @override
  Future<List<Category>> getCategories() =>
      remoteCategorySource.getCategories();

  @override
  Future<bool> addCategory(Category category) =>
      remoteCategorySource.addCategory(category);

  @override
  Future<bool> updateCategory(Category category) =>
      remoteCategorySource.updateCategory(category);

  @override
  Future<bool> deleteCategory(Category category) =>
      remoteCategorySource.deleteCategory(category);
}
