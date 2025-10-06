import '../../domain/models/activity.dart';

abstract class IActivitySource {
  Future<List<Activity>> getActivities();

  Future<bool> addActivity(Activity activity);

  Future<bool> updateActivity(Activity activity);

  Future<bool> deleteActivity(Activity activity);

  Future<bool> deleteActivities();
}
