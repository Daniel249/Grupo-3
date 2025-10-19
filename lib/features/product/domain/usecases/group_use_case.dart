import '../models/group.dart';
import '../repositories/i_group_repository.dart';

class GroupUseCase {
  final IGroupRepository groupRepository;

  GroupUseCase(this.groupRepository);

  Future<List<Group>> getGroups() {
    return groupRepository.getGroups();
  }

  Future<bool> addGroup(Group group) {
    return groupRepository.addGroup(group);
  }

  Future<bool> updateGroup(Group group) {
    return groupRepository.updateGroup(group);
  }

  Future<bool> deleteGroup(Group group) {
    return groupRepository.deleteGroup(group);
  }
}
