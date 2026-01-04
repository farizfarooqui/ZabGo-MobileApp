import 'package:demo/Controllers/NavBarController.dart';
import 'package:demo/Views/HomeScreen.dart';
import 'package:demo/Views/MessageScreen.dart';
import 'package:demo/Views/MyRideScreen.dart';
import 'package:demo/Views/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo/Utils/Constants.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavBarController controller =
        Get.put(NavBarController(), permanent: true);

    final List<Widget> pages = [
      const HomeScreen(),
      const MyRidesScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
          backgroundColor: colorPrimary,
          body: pages[controller.currentIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            type: BottomNavigationBarType.fixed,
            backgroundColor: colorPrimary,
            selectedItemColor: colorSecondary,
            unselectedItemColor: Colors.grey,
            onTap: controller.changeTab,
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Obx(() {
                  final count =
                      controller.myRidesController.getPendingRequestsCount();
                  return Stack(
                    children: [
                      const Icon(Icons.directions_car),
                      if (count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                label: 'My Rides',
              ),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.chat), label: 'Chats'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ));
  }
}
