import 'dart:async';

import 'package:demo/Utils/Constants.dart';
import 'package:demo/Views/OnBoardingScreen.dart';
import 'package:demo/Widgets/LoaderButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _firstLineController;
  late AnimationController _secondLineController;
  late AnimationController _buttonFadeController;
  late Animation<double> _buttonOpacity;
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _firstLineController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _secondLineController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonFadeController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _buttonOpacity =
        Tween<double>(begin: 0, end: 1).animate(_buttonFadeController);
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _showLogo = true);
    _logoController.forward();
    await Future.delayed(const Duration(seconds: 2));

    _firstLineController.forward();
    await _firstLineController.animationCompleted();

    // Add a slight delay before starting the second animation
    await Future.delayed(const Duration(milliseconds: 100));
    _secondLineController.forward();
    await _secondLineController.animationCompleted();

    _buttonFadeController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _firstLineController.dispose();
    _secondLineController.dispose();
    _buttonFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: colorSecondary, end: colorPrimary),
      duration: const Duration(seconds: 1),
      builder: (context, color, child) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: color,
            systemNavigationBarColor: color,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark,
          ),
        );
        return Scaffold(
          backgroundColor: color,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_showLogo)
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _logoController,
                        curve: Curves.elasticOut,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 300,
                        height: 300,
                      ),
                    ),
                  SizedBox(height: Get.height * 0.08),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAnimatedLine(
                          text: "Ride Together &",
                          controller: _firstLineController,
                        ),
                        _buildAnimatedLine(
                          text: "Save Together!",
                          controller: _secondLineController,
                        ),  
                      ],
                    ),
                  ),
                  SizedBox(height: Get.height * 0.08),
                  FadeTransition(
                    opacity: _buttonOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: SizedBox(
                        height: 65,
                        child: LoaderButton2(
                          radius: 30,
                          onPressed: () {
                            Get.offAll( const OnboardingScreen());
                          },
                          buttonName: 'Click here to get Connected!',
                          btnTextColor: colorPrimary,
                          isIcon: false,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Get.height * 0.08),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLine({
    required String text,
    required AnimationController controller,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(text.length, (charIndex) {
            final charStart = charIndex / text.length;
            final charOpacity = (controller.value - charStart) * text.length;

            return Opacity(
              opacity: charOpacity.clamp(0.0, 1.0),
              child: Text(
                text[charIndex],
                style: GoogleFonts.poppins(
                  textStyle:  const TextStyle(
                    fontSize: 24,
                    color: colorSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

extension AnimationControllerExtension on AnimationController {
  Future<void> animationCompleted() async {
    Completer<void> completer = Completer<void>();
    void listener(status) {
      if (status == AnimationStatus.completed) {
        completer.complete();
        removeStatusListener(listener);
      }
    }

    addStatusListener(listener);
    return completer.future;
  }
}
