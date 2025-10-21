import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/course.dart';
import '../../domain/use_case/course_usecase.dart';

class CourseController extends GetxController {
  final RxList<Course> _courses = <Course>[].obs;
  final CourseUseCase courseUseCase = Get.find();
  final RxBool isLoading = false.obs;
  List<Course> get courses => _courses;

  @override
  void onInit() {
    getCourses();
    super.onInit();
  }

  getCourses() async {
    logInfo("CourseController: Getting courses");
    isLoading.value = true;
    _courses.value = await courseUseCase.getCourses();
    isLoading.value = false;
  }

  addCourse(
    String name,
    String desc,
    List<String> students,
    String teacher,
  ) async {
    logInfo("ProductController: Add course");
    await courseUseCase.addCourse(name, desc, students, teacher);
    getCourses();
  }

  Future<void> updateCourse(Course course) async {
    logInfo("ProductController: Update course");
    await courseUseCase.updateCourse(course);
    await getCourses();
  }

  Future<void> deleteCourse(Course p) async {
    logInfo("ProductController: Delete product");

    await courseUseCase.deleteCourse(p);
    await getCourses();
  }

  /*
  void deleteProducts() async {
    logInfo("ProductController: Delete all products");
    isLoading.value = true;
    await productUseCase.deleteProducts();
    await getProducts();
    isLoading.value = false;
  } */
}
