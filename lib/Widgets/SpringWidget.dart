// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:animated/animated.dart';
import 'package:flutter/material.dart';

class SpringWidget extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final double intensity;
  const SpringWidget({
    Key? key,
    required this.onTap,
    this.onLongPress,
    required this.child,
    this.intensity = 0.9,
  }) : super(key: key);

  @override
  _SpringWidgetState createState() => _SpringWidgetState();
}

class _SpringWidgetState extends State<SpringWidget> {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        setState(() {
          tapped = true;
        });
      },
      onPanEnd: (details) {
        setState(() {
          tapped = false;
        });
      },
      onPanCancel: () {
        setState(() {
          tapped = false;
        });
      },
      onTap: widget.onTap,
      child: AbsorbPointer(
        child: Animated(
          value: tapped ? widget.intensity : 1,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 100),
          builder: (context, child, animation) => Transform.scale(
            scale: animation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
