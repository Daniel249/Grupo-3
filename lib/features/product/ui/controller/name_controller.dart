import 'package:get/get.dart';

class NameController extends GetxController {
  final RxString _name = ''.obs;

  String get text => _name.value;
  set text(String value) => _name.value = value;

  void clear() => _name.value = '';
}