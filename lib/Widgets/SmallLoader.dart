import 'dart:io';
import 'package:demo/Utils/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmallLoader extends StatelessWidget {
  final bool adaptive;
  final Color? color; // optional

  const SmallLoader({
    super.key,
    this.adaptive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final loaderColor = color ?? colorPrimary;

    return Platform.isIOS
        ? CupertinoActivityIndicator(
            color: loaderColor,
          )
        : SizedBox(
            height: 15,
            width: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: loaderColor,
              valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
            ),
          );
  }
}
