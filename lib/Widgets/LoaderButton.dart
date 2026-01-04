
// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:demo/Widgets/SmallLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/constants.dart';

class LoaderButton extends StatelessWidget {
  final text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color borderColor;

  final Color textColor;

  const LoaderButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    Color? backgroundColor,
    this.textColor = Colors.white,
    this.borderColor = Colors.white,
  }) : backgroundColor = backgroundColor ?? colorSecondary,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w800, fontFamily: "poppins"),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: isLoading
          ?  const SmallLoader()
          : Text(text,
              style: TextStyle(
                color: textColor,
              )),
    );
  }
}

class LoaderButton2 extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String buttonName;
  final String? iconsPath;
  final bool isIcon;
  final bool isGrey;
  final bool isSocialBtn;
  final double radius;
  final Color? buttonColor;
  final Color? btnTextColor;
  const LoaderButton2(
      {Key? key,
      this.onPressed,
      this.isLoading = false,
      required this.buttonName,
      this.isIcon = true,
      this.isGrey = false,
      this.iconsPath,
      this.radius = 13.0,
      this.buttonColor,
      this.btnTextColor,
      this.isSocialBtn = false})
      : super(key: key);

  @override
  State<LoaderButton2> createState() => _LoaderButton2State();
}

class _LoaderButton2State extends State<LoaderButton2> {
  bool tapped = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
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
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: tapped ? 0.5 : 1,
        child: Container(
          // duration: const Duration(milliseconds: 250),
          width: MediaQuery.of(context).size.width,
          height: 50,
          decoration: BoxDecoration(
            color: widget.isSocialBtn
                ? const Color(0xffD9D9D9)
                : widget.isGrey
                    ? colorSecondary
                    : widget.buttonColor ?? colorSecondary,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: widget.isLoading
              ?  const Center(
                  child: SmallLoader(
                  color: Colors.white,
                ))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isGrey && widget.iconsPath != null)
                      SvgPicture.asset(widget.iconsPath!),
                    if (widget.isGrey)
                      const SizedBox(
                        width: 5,
                      ),
                    if (widget.buttonName.isNotEmpty)
                      Text(
                        widget.buttonName,
                        style: TextStyle(
                            color: widget.isGrey
                                ? colorPrimary
                                : widget.btnTextColor ??
                                    colorPrimary.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins"),
                      ),
                    if (widget.isIcon)
                      const SizedBox(
                        width: 8,
                      ),
                    if (widget.isIcon)
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: colorSecondary,
                        size: 15,
                      )
                  ],
                ),
        ),
      ),
    );
  }
}
