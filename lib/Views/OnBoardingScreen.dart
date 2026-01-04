import 'package:demo/Controllers/OnBoardingController.dart';
import 'package:demo/Controllers/SignUpController.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
   const OnboardingScreen({super.key});
  OnboardingController get controller => Get.put(OnboardingController());
  SignUpController get signUpcontroller => Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:  const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: colorPrimary,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: Get.height * 0.05),
                //logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: Get.height * 0.05),
                Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Join ZABGO",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 25,
                            color: colorSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                       const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Join your campus ride community. Share rides with fellow students, save money, and make new friends along the way.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle:  const TextStyle(
                              fontSize: 14,
                              color: hintColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                 const Spacer(),
                Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.goToWelcomeBackScreen();
                        },
                        child: AnimatedOpacity(
                          duration:  const Duration(milliseconds: 250),
                          opacity: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 56,
                            decoration: BoxDecoration(
                                color: colorSecondary,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                    width: 1,
                                    color: hintColor.withOpacity(0.5))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 const SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  width: 30,
                                  height: 24,
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/svg/email.svg",
                                      width: 20,
                                      fit: BoxFit.contain,
                                      color: colorPrimary,
                                    ),
                                  ),
                                ),
                                 const SizedBox(width: 15),
                                 const Text(
                                  'Continue with Student ID',
                                  style: TextStyle(
                                      color: colorPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Poppins"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.010),
                       const SizedBox(
                        height: 12,
                      ),
                    ],
                  )),
                ),
                SizedBox(height: Get.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
