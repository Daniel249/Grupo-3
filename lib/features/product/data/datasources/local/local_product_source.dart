import '../../../domain/models/activity.dart';
import '../i_remote_activity_source.dart';

class LocalActivitySource implements IActivitySource {
  final List<Activity> _activities = <Activity>[];

  LocalActivitySource();

  @override
  Future<bool> addActivity(Activity activity) {
    activity.id = DateTime.now().millisecondsSinceEpoch.toString();
    _activities.add(activity);
    return Future.value(true);
  }

  @override
  Future<bool> deleteActivity(Activity activity) {
    _activities.remove(activity);
    return Future.value(true);
  }

  @override
  Future<bool> deleteActivities() {
    _activities.clear();
    return Future.value(true);
  }

  @override
  Future<List<Activity>> getActivities() {
    return Future.value(_activities);
  }

  @override
  Future<bool> updateActivity(Activity activity) {
    var index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
      return Future.value(true);
    }
    return Future.value(false);
  }
}
