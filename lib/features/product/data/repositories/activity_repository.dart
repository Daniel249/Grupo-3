import '../../domain/repositories/i_activity_repository.dart';
import '../datasources/i_remote_activity_source.dart';
import '../../domain/models/activity.dart';

class ActivityRepository implements IActivityRepository {
  late IActivitySource userSource;

  ActivityRepository(this.userSource);

  @override
  Future<List<Activity>> getActivities() async =>
      await userSource.getActivities();

  @override
  Future<bool> addActivity(Activity activity) async =>
      await userSource.addActivity(activity);

  @override
  Future<bool> updateActivity(Activity activity) async =>
      await userSource.updateActivity(activity);

  @override
  Future<bool> deleteActivity(Activity activity) async =>
      await userSource.deleteActivity(activity);

  @override
  Future<bool> deleteActivities() async => await userSource.deleteActivities();
}
