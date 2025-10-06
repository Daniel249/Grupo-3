import 'package:loggy/loggy.dart';
import '../../domain/models/activity.dart';
import 'package:http/http.dart' as http;

import 'i_remote_activity_source.dart';

class RemoteActivitySource implements IActivitySource {
  final http.Client httpClient;

  RemoteActivitySource(this.httpClient);

  @override
  Future<List<Activity>> getActivities() async {
    List<Activity> activities = [];

    return Future.value(activities);
  }

  @override
  Future<bool> addActivity(Activity activity) async {
    logInfo("Web service, Adding activity $activity");
    return Future.value(true);
  }

  @override
  Future<bool> updateActivity(Activity activity) async {
    logInfo("Web service, Updating activity with id ${activity.id}");
    return Future.value(true);
  }

  @override
  Future<bool> deleteActivity(Activity activity) async {
    logInfo("Web service, Deleting activity with id ${activity.id}");
    return Future.value(true);
  }

  @override
  Future<bool> deleteActivities() async {
    List<Activity> activities = await getActivities();
    for (var activity in activities) {
      await deleteActivity(activity);
    }
    return Future.value(true);
  }
}
