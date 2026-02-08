import 'dart:developer';
import 'package:demo/Model/UserModel.dart';
import 'package:demo/Service/Internet.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:demo/Utils/Utils.dart';
import 'package:demo/Views/WelcomeBackScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  final box = GetStorage();

  Rxn<UserModel> currentUser = Rxn<UserModel>();
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  void _initializeUser() async {
    // First try to load from local storage
    final data = box.read('userData');
    if (data != null) {
      currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(data));
      isLoggedIn(true);
      log("User loaded from local storage: ${currentUser.value?.name}");
    }

    // Then verify with Supabase auth and sync if needed
    final authUser = supabase.auth.currentUser;
    if (authUser != null) {
      // If we have auth but no local data, fetch from database
      if (currentUser.value == null) {
        await fetchUserFromSupabase();
      }
    } else {
      // If no auth session, clear local data
      if (currentUser.value != null) {
        await logout();
      }
    }
  }

  Future<void> saveUser(UserModel user) async {
    currentUser.value = user;
    isLoggedIn(true);
    await box.write('userData', user.toJson());
    log("User saved locally: ${user.name}");
  }

  Future<void> fetchUserFromSupabase() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      final res =
          await supabase.from('users').select().eq('id', authUser.id).single();

      final user = UserModel.fromJson(res);
      await saveUser(user);
    } catch (e) {
      log("FetchUser Error: $e");
    }
  }

  Future<void> logout() async {
    final isOnline = await InternetService.hasInternet();
    if (!isOnline) {
      Utils.showError(
          'No Internet', 'Please connect to the internet and try again.');
      return;
    }
    await supabase.auth.signOut();
    await box.erase();
    currentUser.value = null;
    isLoggedIn(false);
    Get.deleteAll(force: true);
    Get.offAll(() => WelcomeBackScreen());
    Get.snackbar(
      "Logged Out",
      "You have been successfully logged out.",
      backgroundColor: colorSecondary,
      colorText: Colors.white,
    );
  }
}
