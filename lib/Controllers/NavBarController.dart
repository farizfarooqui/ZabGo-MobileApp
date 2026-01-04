import 'dart:developer';
import 'package:get/get.dart';
import 'package:demo/Controllers/ProfileContoller.dart';
import 'package:demo/Controllers/MyRidesController.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NavBarController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final supabase = Supabase.instance.client;
  late final ProfileController profileController;
  late final MyRidesController myRidesController;

  @override
  void onInit() {
    super.onInit();
    log("NavBarController initialized ✅");
    profileController = Get.put(ProfileController(), permanent: true);
    myRidesController = Get.put(MyRidesController(), permanent: true);
  }
  // ✅ Tab change logic
  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 1 && myRidesController.getPendingRequestsCount() > 0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        myRidesController.changeTab(2);
      });
    }
  }
}
