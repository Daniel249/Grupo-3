import 'package:get/get.dart';

class StudentsListController extends GetxController {
  final RxList<String> _students = <String>[].obs;

  List<String> get text => _students;
  set text(List<String> value) {
    _students.value = value;
  }

  void add(String student) => _students.add(student);
  void clear() => _students.clear();
}
