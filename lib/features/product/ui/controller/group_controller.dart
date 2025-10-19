import 'package:get/get.dart';

import '../../domain/models/group.dart';
import '../../domain/usecases/group_use_case.dart';

class GroupController extends GetxController {
  final GroupUseCase _groupUseCase;

  GroupController(this._groupUseCase);

  final RxList<Group> groups = <Group>[].obs;

  Future<void> getGroups() async {
    groups.value = await _groupUseCase.getGroups();
  }

  Future<bool> addGroup(Group group) async {
    final result = await _groupUseCase.addGroup(group);
    if (result) {
      await getGroups();
    }
    return result;
  }

  Future<bool> updateGroup(Group group) async {
    final result = await _groupUseCase.updateGroup(group);
    if (result) {
      await getGroups();
    }
    return result;
  }

  Future<bool> deleteGroup(Group group) async {
    final result = await _groupUseCase.deleteGroup(group);
    if (result) {
      await getGroups();
    }
    return result;
  }
}
