import 'package:get/get.dart';

class DescriptionController extends GetxController {
  final RxString _description = ''.obs;

  String get text => _description.value;
  set text(String value) => _description.value = value;

  void clear() => _description.value = '';
}
