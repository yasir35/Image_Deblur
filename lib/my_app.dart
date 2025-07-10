import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_2/screens/auth/login_screen.dart';
import 'package:task_2/screens/auth/registration_screen.dart';
import 'package:task_2/screens/home/home_screen.dart';
import 'package:task_2/screens/image%20Enhance/enhance_image.dart';
import 'package:task_2/screens/policy/privacypolicy_screen.dart';
import 'package:task_2/screens/splash/splash_screen.dart';
import 'package:task_2/utils/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Image D-Bluring',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: tPrimaryColor),
          useMaterial3: true,
        ),
        home: SplashScreen(),
        getPages: [
          GetPage(name: '/loginscreen', page: () => LoginScreen()),
          GetPage(name: '/registerscreen', page: () => RegisterScreen()),
          GetPage(name: '/homescreen', page: () => HomeScreen()),
          GetPage(
              name: '/privacypolicyscreen', page: () => PrivacyPolicyScreen()),
          GetPage(name: '/imageEnhance', page: () => ImageEnhancement()),
        ]);
  }
}
