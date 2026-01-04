import 'package:demo/Utils/Constants.dart';
import 'package:demo/Widgets/BackButtonWidget.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar._({
    required this.title,
    this.trailing,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  static PreferredSize create(
          {required String title,
          List<Widget>? trailing,
          Widget? leading,
          bool automaticallyImplyLeading = true,
          Color? textColor,
          Color? backgroundColor,
          double? fontSize,
          FontWeight? fontWeight}) =>
      PreferredSize(
          preferredSize: const Size(double.infinity, 56),
          child: CustomAppBar._(
            title: title,
            automaticallyImplyLeading: automaticallyImplyLeading,
            trailing: trailing,
            leading: leading,
            backgroundColor: backgroundColor,
            textColor: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ));

  final String title;
  final List<Widget>? trailing;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final dynamic automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(
            fontWeight: fontWeight ?? FontWeight.w400,
            color: textColor ?? colorPrimary,
            fontSize: fontSize ?? 18),
      ),
      centerTitle: true,
      actions: trailing,
      backgroundColor: backgroundColor ?? colorSecondary,
      leading: leading ??
          BackButtonWidget(
            iconColor: textColor ?? colorPrimary,
          ),
      elevation: 0,
    );
  }
}
