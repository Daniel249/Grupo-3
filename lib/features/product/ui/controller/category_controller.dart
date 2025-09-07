import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/use_case/category_usecase.dart';

class CategoryController extends GetxController {
  final RxList<Category> _categories = <Category>[].obs;
  final CategoryUseCase categoryUseCase = Get.find();
  final RxBool isLoading = false.obs;
  List<Category> get categories => _categories;

  Future<void> getCategories() async {
    isLoading.value = true;
    _categories.value = await categoryUseCase.getCategories();
    isLoading.value = false;
  }

  Future<void> addCategory(Category category) async {
    await categoryUseCase.addCategory(category);
    await getCategories();
  }

  Future<void> updateCategory(Category category) async {
    await categoryUseCase.updateCategory(category);
    await getCategories();
  }

  Future<void> deleteCategory(Category category) async {
    await categoryUseCase.deleteCategory(category);
    await getCategories();
  }
}
