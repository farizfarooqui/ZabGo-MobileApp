import 'dart:developer';
import 'dart:io';
import 'package:demo/Controllers/MyRidesController.dart';
import 'package:demo/Controllers/NavBarController.dart';
import 'package:demo/Controllers/ProfileContoller.dart';
import 'package:demo/Model/UserModel.dart';
import 'package:demo/Service/OCR.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo/Views/NavBar.dart';
import 'package:demo/Utils/Utils.dart';

class CreateAccountController extends GetxController {
  final box = GetStorage();
  // Observables
  var isPasswordObscured = true.obs;
  var isLoading = false.obs;
  final List<int> semesters = List.generate(8, (index) => index + 1);
  var selectedGender = ''.obs;

  // Text controllers
  late final TextEditingController nameController;
  late final TextEditingController studentIdController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController departmentController;
  late final TextEditingController yearController;
  late final TextEditingController semesterController;
  late final TextEditingController addressController;

  // Image paths (front & back ID)
  var frontImagePath = ''.obs;
  var backImagePath = ''.obs;

  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  // Pick image
  Future<void> pickImage(bool isFront) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (isFront) {
          frontImagePath.value = pickedFile.path;
        } else {
          backImagePath.value = pickedFile.path;
        }
      }
    } catch (e) {
      Utils.showError("Image Error", "Failed to pick image.");
    }
  }

  Future<void> signUpWithSupabase() async {
    if (selectedGender.value.isEmpty) {
      Utils.showError("Missing Field", "Please select your gender.");
      return;
    }

    if (nameController.text.isEmpty ||
        studentIdController.text.isEmpty ||
        // emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        addressController.text.isEmpty ||
        departmentController.text.isEmpty ||
        yearController.text.isEmpty ||
        semesterController.text.isEmpty ||
        frontImagePath.isEmpty ||
        backImagePath.isEmpty) {
      Utils.showError("Missing Fields",
          "Please fill all details and upload both ID images.");
      return;
    }

    try {
      isLoading(true);

      // ✅ STEP 1: Validate university ID via OCR
      final frontFile = File(frontImagePath.value);
      final backFile = File(backImagePath.value);

      final frontText = await OCRValidator.extractText(frontFile);
      // final backText = await OCRValidator.extractText(backFile);
      // final combinedText = "${frontText ?? ''} ${backText ?? ''}";

      if (!OCRValidator.isValidUniversityID(frontText ?? '')) {
        Utils.showError("Invalid University ID",
            "Your uploaded ID card doesn't appear to be a valid SZABIST student ID. Please upload a clear front and back image of your card.");
        return;
      }

      // ✅ STEP 2: Create user in Supabase Auth
      final AuthResponse res = await supabase.auth.signUp(
        // email: emailController.text.trim(),
        email: "${studentIdController.text.trim()}@szabist.edu.pk",
        password: passwordController.text.trim(),
      );

      final user = res.user;
      if (user == null) throw Exception("User not created");

      // ✅ STEP 3: Upload images to Supabase Storage
      final frontUrl = await uploadToSupabaseStorage(
          frontImagePath.value, user.id, "frontID");
      final backUrl =
          await uploadToSupabaseStorage(backImagePath.value, user.id, "backID");

      // ✅ STEP 4: Prepare user data
      final userData = {
        'id': user.id,
        'name': nameController.text.trim(),
        'gender': selectedGender.value,
        'student_id': studentIdController.text.trim(),
        // 'email': emailController.text.trim(),
        'email': "${studentIdController.text.trim()}@szabist.edu.pk",
        'department': departmentController.text.trim(),
        'year': yearController.text.trim(),
        'semester': semesterController.text.trim(),
        'address': addressController.text.trim(),
        'front_id_url': frontUrl,
        'back_id_url': backUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      // ✅ STEP 5: Save in Supabase DB
      await supabase.from('users').upsert(userData);

      Utils.showSuccess("Success!", message: "Account created successfully.");

      // ✅ STEP 6: Initialize controllers
      final profileController = Get.put(ProfileController(), permanent: true);
      Get.put(MyRidesController(), permanent: true);
      Get.put(NavBarController(), permanent: true);

      await profileController.saveUser(UserModel.fromJson(userData));
      await box.write('userData', userData);
      await box.write('isLoggedIn', true);

      Get.offAll(() => const NavBar());
    } on AuthApiException catch (e) {
      if (e.message.contains("User already registered")) {
        Utils.showError(
          "Signup Failed",
          "This student ID is already registered. Please login instead.",
        );
      } else {
        Utils.showError("Signup Failed", e.message);
      }
    } catch (e) {
      log("SignUp Error: $e");
      Utils.showError("Signup Failed", e.toString());
    } finally {
      isLoading(false);
    }
  }

  // ✅ Upload image to Supabase Storage
  Future<String> uploadToSupabaseStorage(
      String filePath, String uid, String type) async {
    final file = File(filePath);
    final fileName = "$uid-$type-${DateTime.now().millisecondsSinceEpoch}.jpg";

    // Upload to your 'users' bucket
    await supabase.storage.from('users').upload(fileName, file);

    // Get public URL
    final publicUrl = supabase.storage.from('users').getPublicUrl(fileName);
    return publicUrl;
  }

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    studentIdController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    departmentController = TextEditingController();
    yearController = TextEditingController();
    semesterController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    studentIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    departmentController.dispose();
    yearController.dispose();
    semesterController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
