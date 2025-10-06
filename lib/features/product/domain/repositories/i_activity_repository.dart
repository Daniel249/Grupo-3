import '../models/activity.dart';

abstract class IActivityRepository {
  Future<List<Activity>> getActivities();

  Future<bool> addActivity(Activity p);

  Future<bool> updateActivity(Activity p);

  Future<bool> deleteActivity(Activity p);

  Future<bool> deleteActivities();
}
