import '../../../domain/models/category.dart';
import '../i_category_source.dart';
import '../../../domain/models/group.dart';

class LocalCategorySource implements ICategorySource {
  final List<Category> _categories = <Category>[];

  LocalCategorySource() {
    // Initial dummy data
    _categories.addAll([
      Category(
        id: 1,
        name: 'Category 1',
        courseID: 1,
        groupSize: 3,
        groups: [Group(id: 1, name: 'Group 1', students: <String>[])],
        isRandomSelection: false,
      ),
      Category(
        id: 2,
        name: 'Category 2',
        courseID: 1,
        groupSize: 3,
        groups: [Group(id: 2, name: 'Group 2', students: <String>[])],
        isRandomSelection: true,
      ),
      Category(
        id: 3,
        name: 'Category 3',
        courseID: 2,
        groupSize: 3,
        groups: [
          Group(id: 2, name: 'Group 2', students: ["Alice", "Bob"]),
          Group(id: 3, name: 'Group 1', students: ["Charlie"]),
        ],
        isRandomSelection: true,
      ),
    ]);
  }

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
