import '../../domain/models/activity.dart';

abstract class IActivitySource {
  Future<List<Activity>> getActivities(String? courseId);

  Future<bool> addActivity(Activity activity);

  Future<bool> updateActivity(Activity activity);

  Future<bool> deleteActivity(Activity activity);

  Future<bool> deleteActivities();
}
