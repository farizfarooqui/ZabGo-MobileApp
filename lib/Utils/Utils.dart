// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:demo/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static Random random = Random();
  static void showError(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: colorSecondary,
        title: title,
        message: message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        snackStyle: SnackStyle.GROUNDED,
      ));
    }
  }

  static void showSuccess(String title,
      {String message = "No further message"}) {
    Get.showSnackbar(
      GetSnackBar(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 12,
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.check_circle_outline,
            color: Colors.white, size: 28),
        titleText: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        animationDuration: const Duration(milliseconds: 400),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeIn,
      ),
    );
  }

  static Color parseHexColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static void launchUrlNavigate(String url) async {
    try {
      final uri = Uri.parse(url);

      // Try different launch modes
      bool launched = false;

      // First try external application
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('External launch failed: $e');
      }

      // If external fails, try platform default
      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          print('Platform default launch failed: $e');
        }
      }

      // If both fail, try in-app browser
      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
        } catch (e) {
          print('In-app launch failed: $e');
        }
      }

      if (!launched) {
        print('Could not launch $url');
        // Optional: Show a snackbar or dialog to the user
      }
    } catch (e) {
      print('Error parsing URL: $e');
    }
  }

  /// Converts ISO date string to a readable format like "Feb 22, 2025"
  static String formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      final formatter = DateFormat('MMM dd, yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
