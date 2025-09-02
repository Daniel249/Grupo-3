import '../models/user.dart';
import '../repositories/i_student_repository.dart';

class StudentUseCase {
  late IStudentRepository repository;

  StudentUseCase(this.repository);

  Future<List<User>> getUsers() async => await repository.getUsers();

  Future<void> addUser(String name) async =>
      await repository.addUser(User(name: name));

  Future<void> updateUser(User user) async => await repository.updateUser(user);

  Future<void> deleteUser(User user) async => await repository.deleteUser(user);

  //Future<void> deleteProducts() async => await repository.deleteProducts();
}
