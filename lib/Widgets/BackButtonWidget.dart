import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({
    super.key,
    this.iconColor,
  });
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    // Check if we can pop the screen
    bool canPop = Navigator.of(context).canPop();

    // Return an empty Container if we can't pop
    if (!canPop) return Container();

    // Check the platform and return appropriate icon
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoNavigationBarBackButton(
        // color: iconColor ?? themeController.colorIcon2,
        // color: Colors.white,
        color: iconColor,
        onPressed: () => Get.back(),
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.arrow_back,
          // color: iconColor ?? themeController.colorIcon2,
          // color: Colors.white,
          color: iconColor,
        ),
        onPressed: () => Get.back(),
      );
    }
  }
}
