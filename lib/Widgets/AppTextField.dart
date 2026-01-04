// ignore_for_file: file_names

import 'package:demo/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/Constants.dart' as constant;

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintName;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextStyle? style;
  final bool readOnly;
  final bool? enable;
  final void Function()? onTap;
  final int? maxLength;
  final int? maxLines;
  final Color? cursorColor;
  final Color? fillColor;
  final Color? hintColor;
  final bool isSuffix;
  final List<TextInputFormatter>? inputFormatters;
  final String? fixedDomain;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintName,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.style,
    this.readOnly = false,
    this.onTap,
    this.enable,
    this.maxLength,
    this.maxLines,
    this.inputFormatters,
    this.cursorColor,
    this.fillColor,
    this.hintColor,
    this.isSuffix = false,
    this.fixedDomain,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: cursorColor,
      inputFormatters: inputFormatters,
      enabled: enable,
      maxLength: maxLength,
      maxLines: maxLines ?? 1,
      onTap: onTap,
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      style: style ??
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorSecondary,
          ),
      decoration: InputDecoration(
        hintText: hintName,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: constant.hintColor,
        ),
        suffixText: fixedDomain,
        suffixStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        suffixIcon: isSuffix
            ? (suffixIcon ??
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.check, color: colorSecondary),
                ))
            : null,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: fillColor ?? constant.hintColor.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: constant.hintColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: constant.hintColor,
            width: 1.0,
          ),
        ),
      ),
      keyboardType: keyboardType,
    );
  }
}
