import '../models/group.dart';

abstract class IGroupRepository {
  Future<List<Group>> getGroups();
  Future<bool> addGroup(Group group);
  Future<bool> updateGroup(Group group);
  Future<bool> deleteGroup(Group group);
}
