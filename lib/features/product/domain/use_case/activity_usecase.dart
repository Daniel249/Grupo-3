import '../models/activity.dart';
import '../repositories/i_activity_repository.dart';

class ActivityUseCase {
  late IActivityRepository repository;

  ActivityUseCase(this.repository);

  Future<List<Activity>> getActivities() async =>
      await repository.getActivities();

  Future<void> addActivity(
    String name,
    String description,
    String course,
  ) async => await repository.addActivity(
    Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      course: course,
    ),
  );

  Future<void> updateActivity(Activity user) async =>
      await repository.updateActivity(user);

  Future<void> deleteActivity(Activity user) async =>
      await repository.deleteActivity(user);

  Future<void> deleteActivities() async => await repository.deleteActivities();
}
