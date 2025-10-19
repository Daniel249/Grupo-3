import '../../data/datasources/i_group_source.dart';
import '../../domain/models/group.dart';
import '../../domain/repositories/i_group_repository.dart';

class GroupRepository implements IGroupRepository {
  final IGroupSource groupSource;

  GroupRepository(this.groupSource);

  @override
  Future<List<Group>> getGroups() {
    return groupSource.getGroups();
  }

  @override
  Future<bool> addGroup(Group group) {
    return groupSource.addGroup(group);
  }

  @override
  Future<bool> updateGroup(Group group) {
    return groupSource.updateGroup(group);
  }

  @override
  Future<bool> deleteGroup(Group group) {
    return groupSource.deleteGroup(group);
  }
}
