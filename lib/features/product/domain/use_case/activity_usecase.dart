import '../models/activity.dart';
import '../repositories/i_activity_repository.dart';

class ActivityUseCase {
  late IActivityRepository repository;

  ActivityUseCase(this.repository);

  Future<List<Activity>> getActivities(String? courseId) async =>
      await repository.getActivities(courseId);

  Future<void> addActivity(Activity activity) async =>
      await repository.addActivity(activity);

  Future<void> updateActivity(Activity activity) async =>
      await repository.updateActivity(activity);

  Future<void> deleteActivity(Activity activity) async =>
      await repository.deleteActivity(activity);

  Future<void> deleteActivities() async => await repository.deleteActivities();
}
