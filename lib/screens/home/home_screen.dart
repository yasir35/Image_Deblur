import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_2/controller/image_enhance.dart';
import 'package:task_2/utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Function to load user data (image) from Firestore
  Future<String?> _loadUserImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc[
          'imageBase64']; // Assuming imageBase64 is stored in Firestore
    }
    return null;
  }

  Future<String?> _loadUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['username']; // Fetching the 'username' field
    }
    return null;
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tSecondaryColor,
          elevation: 8,
          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Get.toNamed("/loginscreen");
                Get.snackbar("Successfull", "LoggedOut successfully");
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // precacheImage(const AssetImage('assets/images/ab.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    final imageEnhanceController = Get.put(ImageEnhanceController());
    return Scaffold(
      // extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Text(
          "Dashboard",
          style: TextStyle(
              color: ttextColor2,
              fontSize: tlargefontsize(context),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: tsmallspace(context)),
            iconSize: tverylargespace(context),
            onPressed: () async {
              _showConfirmationDialog(context);
            },
            icon: Icon(
              Icons.logout_outlined,
              color: ttextColor2,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/ab.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                // color: const Color.fromARGB(69, 0, 0, 0)
                color: const Color.fromARGB(70, 33, 149, 243)),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.12),
                    FutureBuilder<String?>(
                      future: _loadUserImage(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return CircleAvatar(
                            radius: screenWidth * 0.168,
                            backgroundColor: ttextColor2,
                            child: CircleAvatar(
                              radius: screenWidth * 0.16, // Image radius
                              backgroundImage:
                                  MemoryImage(base64Decode(snapshot.data!)),
                            ),
                          );
                        } else {
                          return CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/default.png"),
                            radius: 50,
                          );
                        }
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder<String?>(
                            future: _loadUsername(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (snapshot.hasData && snapshot.data != null) {
                                return Text(
                                  // snapshot.data!,
                                  "Hello ${snapshot.data!},",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.ptSerif().fontFamily,
                                      color: ttextColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                );
                              } else {
                                return Text(
                                  "Username",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: ttextColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                );
                              }
                            },
                          ),
                          Text(
                            "Welcome to IMAGE D-BLURING USING AI TECHNIQUE",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: GoogleFonts.ptSerif().fontFamily,
                                color: ttextColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.17),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => imageEnhanceController.pickImage(),
                            child: Material(
                              elevation: 12,
                              color: const Color.fromARGB(255, 56, 56, 56),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: screenWidth * 0.4,
                                height: screenWidth * 0.3,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 8, bottom: 8, right: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: ttextColor2,
                                      ),
                                      SizedBox(
                                        height: tmediumspace(context),
                                      ),
                                      Text("Pick Image",
                                          style: TextStyle(
                                              color: ttextColor2,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  tmediumfontsize(context))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed("/privacypolicyscreen");
                            },
                            child: Material(
                              elevation: 12,
                              color: const Color.fromARGB(255, 56, 56, 56),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: screenWidth * 0.4,
                                height: screenWidth * 0.3,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 8, bottom: 8, right: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.privacy_tip_outlined,
                                        color: ttextColor2,
                                      ),
                                      SizedBox(
                                        height: tmediumspace(context),
                                      ),
                                      Text("Privacy & Policy",
                                          style: TextStyle(
                                              // fontFamily:
                                              //     GoogleFonts.playfairDisplay()
                                              //         .fontFamily,
                                              color: ttextColor2,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  tmediumfontsize(context))),
                                    ],
                                  ),
                                ),
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
      }),
    );
  }
}
