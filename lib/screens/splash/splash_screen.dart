import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_2/utils/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 4), () async {
      User? user = FirebaseAuth.instance.currentUser;
      // Get.offAllNamed("/homescreen");
      if (user != null) {
        // If the user is logged in, navigate to the home screen
        Get.offAllNamed("/homescreen");
      } else {
        // If the user is not logged in, navigate to the login screen
        Get.offAllNamed("/loginscreen");
      }
    });

    return Scaffold(
      // backgroundColor: tPrimaryColor,
      body: LayoutBuilder(builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/spl.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.72),
                Text(
                  "IMAGE D-BLURING",
                  style: TextStyle(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      color: tSecondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: tverylargefontsize(context)),
                ),
                SizedBox(height: tsmallspace(context)),
                Text(
                  "using AI technique",
                  style: TextStyle(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      color: tSecondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.036),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
