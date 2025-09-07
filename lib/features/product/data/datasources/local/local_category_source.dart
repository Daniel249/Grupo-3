import '../../../domain/models/category.dart';
import '../i_category_source.dart';

class LocalCategorySource implements ICategorySource {
  final List<Category> _categories = <Category>[];

  @override
  Future<List<Category>> getCategories() => Future.value(_categories);

  @override
  Future<bool> addCategory(Category category) async {
    _categories.add(category);
    return true;
  }

  @override
  Future<bool> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.name == category.name);
    if (index != -1) {
      _categories[index] = category;
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteCategory(Category category) async {
    _categories.removeWhere((c) => c.name == category.name);
    return true;
  }
}
