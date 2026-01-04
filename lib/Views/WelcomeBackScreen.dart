import 'package:demo/Controllers/WelcomeBackController.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:demo/Widgets/AppTextField.dart';
import 'package:demo/Widgets/CustomAppBar.dart';
import 'package:demo/Widgets/LoaderButton.dart';
import 'package:demo/Widgets/SpringWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class WelcomeBackScreen extends StatelessWidget {
  final controller = Get.put(WelcomeBackController());

  WelcomeBackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: systemOverlay,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
        child: Scaffold(
          appBar: CustomAppBar.create(
              leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: colorSecondary,
                  )),
              backgroundColor: colorPrimary,
              title: ""),
          backgroundColor: colorPrimary,
          body: Padding(
            padding: EdgeInsets.fromLTRB(
              defaultPadding,
              10,
              defaultPadding,
              32,
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      'Welcome back ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colorSecondary,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please enter your Id & password to signin.',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 50),
                    AppTextField(
                      controller: controller.emailController,
                      hintName: "ID",
                      fixedDomain: "@szabist.edu.pk",
                      keyboardType: TextInputType.phone,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SvgPicture.asset(
                          "assets/svg/email.svg",
                          color: colorSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Obx(() {
                      return AppTextField(
                        controller: controller.passwordController,
                        hintName: "Password",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SvgPicture.asset(
                            "assets/svg/password.svg",
                            color: colorSecondary,
                          ),
                        ),
                        isSuffix: true,
                        suffixIcon: GestureDetector(
                          onTap: controller.togglePasswordVisibility,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: controller.isPasswordObscured.value
                                ? SvgPicture.asset(
                                    'assets/svg/eye-slash.svg',
                                    color: colorSecondary,
                                  )
                                : SvgPicture.asset(
                                    'assets/svg/eye.svg',
                                    color: colorSecondary,
                                  ),
                          ),
                        ),
                        obscureText: controller.isPasswordObscured.value,
                      );
                    }),
                    const SizedBox(height: 32),
                    Obx(
                      () => LoaderButton2(
                        buttonName: "Log In",
                        isIcon: false,
                        onPressed: controller.signInWithEmailAndPassword,
                        isLoading: controller.isLoading.value,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don’t have an account? ",
                          style: TextStyle(
                            color: hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SpringWidget(
                          onTap: controller.goToSignupScreen,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: colorSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
