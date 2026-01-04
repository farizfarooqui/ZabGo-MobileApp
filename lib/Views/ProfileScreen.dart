import 'package:demo/Controllers/ProfileContoller.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:demo/Views/WelcomeBackScreen.dart';
import 'package:demo/Widgets/SmallLoader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final userData = Get.arguments;

    final bool isOtherUser = userData != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Obx(() {
          final displayName = isOtherUser
              ? (userData['name'] ?? 'User')
              : (controller.currentUser.value?.name ?? 'My Profile');

          return Text(
            isOtherUser ? "$displayName's Profile" : "My Profile",
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        centerTitle: true,
        backgroundColor: colorPrimary,
        elevation: 0,
        actions: [
          if (!isOtherUser)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      "Are you sure you want to logout from your account?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: greyLightColor),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorSecondary,
                        ),
                        onPressed: () async {
                          Get.back();
                          await controller.logout();
                          Get.offAll(() => WelcomeBackScreen());
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: Obx(() {
        final user = isOtherUser
            ? userData
            : controller.currentUser.value?.toJson() ?? {};

        if (user.isEmpty) {
          return const Center(child: SmallLoader());
        }

        final displayName = user['name'] ?? 'Unknown';
        final gender = user['gender'] ?? 'Not specified';
        final number = user['number'] ?? 'Not provided';
        final studentId = user['student_id'] ?? 'Not provided';
        final department = user['department'] ?? 'Not provided';
        final semester = user['semester'] ?? 'Not provided';

        final displayInitial =
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: colorSecondary,
                  child: Text(
                    displayInitial,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person, "Name", displayName),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.wc, "Gender", gender),
                    // const SizedBox(height: 16),
                    // _buildInfoRow(Icons.phone, "Phone Number", number),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.badge, "Student ID", studentId),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.school, "Department", department),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.menu_book, "Semester", semester),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.verified_user,
                      "Status",
                      "Verified Student",
                      valueColor: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Verified Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified,
                        color: Colors.green.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Student ID Verified",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "This user has been verified with valid student credentials",
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ZabGo note for own profile
              if (!isOtherUser)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        "ZabGo Member",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You're part of the secure student ride-sharing community",
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorSecondary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
