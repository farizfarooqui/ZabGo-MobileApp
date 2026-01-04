import 'dart:io';
import 'package:demo/Controllers/CreateAccountController.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:demo/Widgets/SmallLoader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final CreateAccountController controller = Get.put(CreateAccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
          title: const Text(
        'Student Sign-Up',
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      )),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: SmallLoader(color: colorSecondary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    buildTextField(controller.nameController, 'Name', false),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Obx(() => DropdownButtonFormField<String>(
                            value: controller.selectedGender.value.isEmpty
                                ? null
                                : controller.selectedGender.value,
                            decoration: InputDecoration(
                              labelText: "Gender",
                              labelStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.black54),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: colorSecondary, width: 1.5),
                              ),
                            ),
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: colorSecondary),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            elevation: 6,
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Row(
                                  children: [
                                    Icon(Icons.male,
                                        size: 20, color: Colors.blueAccent),
                                    SizedBox(width: 10),
                                    Text("Male"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Row(
                                  children: [
                                    Icon(Icons.female,
                                        size: 20, color: Colors.pinkAccent),
                                    SizedBox(width: 10),
                                    Text("Female"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Row(
                                  children: [
                                    Icon(Icons.transgender,
                                        size: 18, color: Colors.purpleAccent),
                                    SizedBox(width: 10),
                                    Text("Other"),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedGender.value = value;
                              }
                            },
                          )),
                    ),
                    buildTextField(
                        controller.studentIdController, 'Student ID / Reg no:', true),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextField(
                        readOnly: true,
                        controller: controller.studentIdController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 1.5),
                          ),
                          suffixText: "@szabist.edu.pk",
                          suffixStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    buildPasswordField(),
                    buildTextField(
                        controller.addressController, 'Address', false),
                    Row(
                      children: [
                        Expanded(
                            child: buildTextField(
                                controller.departmentController,
                                'Department',
                                false)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: buildTextField(controller.semesterController,
                                'Semester', true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: buildTextField(controller.yearController,
                                'Passing Out Year', true)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildImagePicker(controller, true, "Front ID"),
                        buildImagePicker(controller, false, "Back ID"),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: colorSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.signUpWithSupabase,
                      child: const Text(
                        "SIGN-UP",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Common text field style
  Widget buildTextField(
      TextEditingController ctrl, String label, bool isNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: false)
            : TextInputType.text,
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 15, color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: colorSecondary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Obx(() => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: controller.passwordController,
            obscureText: controller.isPasswordObscured.value,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(fontSize: 15, color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: colorSecondary, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordObscured.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
        ));
  }

  Widget buildImagePicker(
      CreateAccountController c, bool isFront, String label) {
    return Obx(() {
      final path = isFront ? c.frontImagePath.value : c.backImagePath.value;

      return GestureDetector(
        onTap: () => c.pickImage(isFront),
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Stack(
            children: [
              // 📸 Show image or placeholder
              path.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined,
                              size: 40, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(label, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

              // ❌ Cross icon (top-right corner)
              if (path.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      if (isFront) {
                        c.frontImagePath.value = '';
                      } else {
                        c.backImagePath.value = '';
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
