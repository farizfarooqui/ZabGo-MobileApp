import 'package:demo/Utils/Constants.dart';
import 'package:demo/Views/NavBar.dart';
import 'package:demo/Views/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Supabase.initialize(
    url: 'https://reyslwqyvthhebfblnrp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJleXNsd3F5dnRoaGViZmJsbnJwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NDc1NjQsImV4cCI6MjA3NTMyMzU2NH0.FEoTt06L5Rbdc2COBDERZk1FaI2xCr4zHiSJOyy3Hig',
  );
  final box = GetStorage();
  final bool isLoggedIn = box.read('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "ZabGo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: colorSecondary,
          selectionHandleColor: colorSecondary,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: colorPrimary,
          modalBackgroundColor: colorPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: colorPrimary,
          centerTitle: true,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.w400,
            color: colorSecondary,
            fontSize: 15,
          ),
        ),
        scaffoldBackgroundColor: scafoldColor,
        fontFamily: 'poppins',
      ),
      home: isLoggedIn ? const NavBar() : const SplashScreen(),
    );
  }
}
