import '../models/user.dart';

abstract class IStudentRepository {
  Future<List<User>> getUsers();

  Future<bool> addUser(User c);

  Future<bool> updateUser(User c);

  Future<bool> deleteUser(User c);

  //Future<bool> deleteProducts();
}
