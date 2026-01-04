import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const Color colorPrimary = Colors.white;
const Color colorSecondary = Colors.blue;

const Color colorPrimaryNetworking = Color.fromARGB(255, 28, 122, 198);
const Color hintColor = Color(0xffA3A3A3);
const Color lightColor = Color(0xff919191);
const Color unSelectedColorGrey = Color(0xff9F9F9F);

const Color greyLightColor = Color(0xffAAAAAA);

const Color colorAccent = Color(0xFF45594B);
const Color tabSelectedColor = colorAccent;
const Color buttonGreyColor = Color(0xffD3CBDE);
const Color tabUnSelectedColor = Color(0xFF858585);
const Color lightTextColor = Color(0xFF212121);
const Color lightGreys = Color(0xffE7E7E7);
const Color colorLight = Colors.grey;

Color colortrasparent = Colors.grey.withOpacity(0.4);
Color scafoldColor = const Color(0x0ff1ecee);
const LatLng demoLatLng = LatLng(40.7812, 73.965);

// Shadows
const buttonShadow = [
  BoxShadow(
    color: Color(0xFFFE3155),
    spreadRadius: 1.5,
    blurRadius: 4,
    offset: Offset(0, 2),
  ),
];
const backgroundGradient = LinearGradient(
  colors: [
    colorPrimary,
    hintColor,
  ],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

Color galleryTileColor = const Color(0xffebebeb);

double defaultPadding = 16.0;

SystemUiOverlayStyle systemOverlay = const SystemUiOverlayStyle(
  statusBarColor: Colors.white,
  systemNavigationBarColor: Colors.white,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

SystemUiOverlayStyle editSystemOverlay = const SystemUiOverlayStyle(
  statusBarColor: lightGreys,
  systemNavigationBarColor: lightGreys,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new text starts with a space, prevent it
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }

    return newValue;
  }
}
