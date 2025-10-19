import '../../domain/models/group.dart';

abstract class IGroupSource {
  Future<List<Group>> getGroups();
  Future<bool> addGroup(Group group);
  Future<bool> updateGroup(Group group);
  Future<bool> deleteGroup(Group group);
}
