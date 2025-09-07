import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import '../../domain/models/category.dart';
import 'i_category_source.dart';

class RemoteCategorySource implements ICategorySource {
  final http.Client httpClient;

  RemoteCategorySource(this.httpClient);

  @override
  Future<List<Category>> getCategories() async {
    List<Category> categories = [];
    // TODO: Implement actual remote fetch
    return Future.value(categories);
  }

  @override
  Future<bool> addCategory(Category category) async {
    logInfo("Web service, Adding category $category");
    // TODO: Implement actual remote add
    return Future.value(true);
  }

  @override
  Future<bool> updateCategory(Category category) async {
    logInfo("Web service, Updating category $category");
    // TODO: Implement actual remote update
    return Future.value(true);
  }

  @override
  Future<bool> deleteCategory(Category category) async {
    logInfo("Web service, Deleting category $category");
    // TODO: Implement actual remote delete
    return Future.value(true);
  }
}
