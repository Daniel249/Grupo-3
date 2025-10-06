import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/activity.dart';
import '../../domain/use_case/activity_usecase.dart';

class ActivityController extends GetxController {
  final RxList<Activity> _activities = <Activity>[].obs;
  final ActivityUseCase activityUseCase = Get.find();
  final RxBool isLoading = false.obs;
  List<Activity> get activities => _activities;

  @override
  void onInit() {
    getActivities();
    super.onInit();
  }

  getActivities() async {
    logInfo("ActivityController: Getting activities");
    isLoading.value = true;
    _activities.value = await activityUseCase.getActivities();
    isLoading.value = false;
  }

  addActivity(String name, String desc, String course) async {
    logInfo("ActivityController: Add activity");
    await activityUseCase.addActivity(name, desc, course);
    getActivities();
  }

  updateActivity(Activity activity) async {
    logInfo("ActivityController: Update activity");
    await activityUseCase.updateActivity(activity);
    await getActivities();
  }

  void deleteActivity(Activity activity) async {
    logInfo("ActivityController: Delete activity");

    await activityUseCase.deleteActivity(activity);
    await getActivities();
  }

  void deleteProducts() async {
    logInfo("ActivityController: Delete all activities");
    isLoading.value = true;
    await activityUseCase.deleteActivities();
    await getActivities();
    isLoading.value = false;
  }
}
