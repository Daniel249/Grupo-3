import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/use_case/category_usecase.dart';
import '../../domain/models/group.dart';

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
    await categoryUseCase.addCategory(
      name,
      isRandomSelection,
      courseID,
      groupSize,
      groups,
    );
    await getCategories(courseID);
  }

  Future<void> updateCategory(Category category) async {
    await categoryUseCase.updateCategory(category);
    await getCategories(category.courseID);
  }

  Future<void> deleteCategory(Category category) async {
    await categoryUseCase.deleteCategory(category);
    await getCategories(category.courseID);
  }
}
