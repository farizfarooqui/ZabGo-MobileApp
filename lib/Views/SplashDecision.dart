import 'package:demo/Controllers/ProfileContoller.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:demo/Views/NavBar.dart';
import 'package:demo/Views/SplashScreen.dart';
import 'package:demo/Widgets/SmallLoader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashDecision extends StatelessWidget {
  final ProfileController controller;

  const SplashDecision({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Delay small splash for smooth experience
    Future.delayed(const Duration(milliseconds: 800), () {
      if (controller.isLoggedIn.value &&
          controller.currentUser.value != null) {
        Get.offAll(() => const NavBar());
      } else {
        Get.offAll(() => const SplashScreen());
      }
    });

    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SmallLoader(color: colorSecondary),
            SizedBox(height: 16),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
