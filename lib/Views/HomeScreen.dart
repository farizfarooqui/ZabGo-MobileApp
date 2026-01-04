import 'package:demo/Views/OfferRideScreen.dart';
import 'package:demo/Views/AvailableRidesScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:demo/Utils/Constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Responsive padding
    final horizontalPadding = width * 0.06;
    final verticalPadding = height * 0.02;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [colorSecondary, colorPrimary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Text
                Text(
                  "Welcome to",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  "ZabGo",
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  "Your campus ride-sharing companion",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: height * 0.04),

                // Lottie Animation - responsive height
                Center(
                  child: SizedBox(
                    height: height * 0.25, // scales with screen
                    child: Lottie.asset(
                      "assets/images/waitingMan.json",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: height * 0.03),

                // Buttons
                _mainButton(
                  title: "Offer a Ride",
                  icon: Icons.add_circle_outline,
                  color: Colors.greenAccent.shade400,
                  onTap: () => Get.to(() => OfferRideScreen()),
                  height: height,
                ),
                SizedBox(height: height * 0.02),
                _mainButton(
                  title: "Search for a Ride",
                  icon: Icons.search_rounded,
                  color: Colors.blueAccent.shade400,
                  onTap: () => Get.to(() => const AvailableRidesScreen()),
                  height: height,
                ),

                Spacer(),

                // Safety Tip Box
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(height * 0.02),
                  decoration: BoxDecoration(
                    color: colorSecondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: colorSecondary,
                        size: height * 0.035,
                      ),
                      SizedBox(width: width * 0.03),
                      const Expanded(
                        child: Text(
                          "Tip: Always verify the driver's identity before starting your ride.",
                          style: TextStyle(
                            color: colorSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double height,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: height * 0.028),
      label: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, height * 0.075),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        shadowColor: color.withOpacity(0.4),
      ),
    );
  }
}
