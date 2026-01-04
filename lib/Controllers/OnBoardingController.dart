import 'dart:async';
import 'package:demo/Views/WelcomeBackScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  PageController? controller;
  Timer? _timer;
  bool forwardWise = true;

  void _onPageChanged() {
    currentPage.value = (controller?.page ?? 0).round();
  }

  void goToWelcomeBackScreen() {
    Get.to(() => WelcomeBackScreen(), transition: Transition.rightToLeft);
  }

  @override
  void onClose() {
    controller?.removeListener(_onPageChanged);
    controller?.dispose();
    _timer?.cancel();
    super.onClose();
  }

  void onPageChanged(int value) {
    currentPage.value = value;
    if (currentPage.value == 0) {
      forwardWise = true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    controller = PageController(initialPage: 0);
    controller?.addListener(_onPageChanged);
  }
}
