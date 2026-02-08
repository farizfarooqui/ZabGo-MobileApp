import 'dart:developer';
import 'package:demo/Controllers/ProfileContoller.dart';
import 'package:demo/Model/UserModel.dart';
import 'package:demo/Service/Internet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo/Utils/Utils.dart';
import 'package:demo/Views/SignUpScreen.dart';
import 'package:demo/Views/NavBar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WelcomeBackController extends GetxController {
  final box = GetStorage();
  final supabase = Supabase.instance.client;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // States
  var isPasswordObscured = true.obs;
  var isRememberMeChecked = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() =>
      isPasswordObscured.value = !isPasswordObscured.value;

  void toggleRememberMe() =>
      isRememberMeChecked.value = !isRememberMeChecked.value;

  void goToSignupScreen() =>
      Get.to(() => SignUpScreen(), transition: Transition.rightToLeft);

  Future<void> signInWithEmailAndPassword() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Utils.showError('Missing Fields', 'Please enter email & password.');
      return;
    }

    final isOnline = await InternetService.hasInternet();
    if (!isOnline) {
      Utils.showError(
          'No Internet', 'Please connect to the internet and try again.');
      return;
    }

    try {
      isLoading(true);

      // ✅ 1. Login with Supabase Auth
      final AuthResponse res = await supabase.auth.signInWithPassword(
        // email: email,
        email: "$email@szabist.edu.pk",
        password: password,
      );

      final authUser = res.user;
      if (authUser == null) {
        Utils.showError('Login Failed', 'User not found.');
        return;
      }

      // ✅ 2. Fetch full profile from "users" table
      final profileResponse = await supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (profileResponse == null) {
        Utils.showError(
            'No Profile Found', 'Please complete your account setup.');
        return;
      }

      log("Fetched user profile: $profileResponse");

      // ✅ 3. Save using ProfileController (local storage)
      final profileController = Get.put(ProfileController());
      await profileController.saveUser(UserModel.fromJson(profileResponse));
      await box.write('isLoggedIn', true);

      // ✅ 4. Navigate to home
      Utils.showSuccess("Welcome Back!", message: "Login successful.");
      Get.offAll(() => const NavBar());
    } on AuthException catch (e) {
      Utils.showError('Login Failed', '');
      print("AuthException: ${e.message}");
    } catch (e) {
      Utils.showError('Unexpected Error', e.toString());
      log("SignIn Error: $e");
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
