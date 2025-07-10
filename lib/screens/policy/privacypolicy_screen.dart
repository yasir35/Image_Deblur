import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_2/utils/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void _showConfirmationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: tSecondaryColor,
            elevation: 8,
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  Get.snackbar("Successfull", "Logged out successfully");
                },
                child: Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: ttextColor2,
            )),
        backgroundColor: Colors.transparent,
        title: Text(
          "Privacy Policy",
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
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/tb.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
                BoxDecoration(color: const Color.fromARGB(155, 0, 0, 0)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.09),
                  Text(
                    "1. Data Collection and Use",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We collect minimal personal data necessary for user registration and "
                    "authentication purposes only. Any images uploaded for processing are "
                    "handled securely and are not stored permanently on our servers. Data is "
                    "used exclusively for enhancing user experience within the application.",
                    style: TextStyle(fontSize: 16, color: ttextColor2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "2. Image Processing",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Images selected by users for deblurring are processed in real-time "
                    "and are not retained by the application post-processing. We ensure that "
                    "processed images remain private and inaccessible to unauthorized parties.",
                    style: TextStyle(fontSize: 16, color: ttextColor2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "3. Data Security",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We prioritize the security of user data with secure transmission "
                    "protocols and encryption. Personal and session information is stored "
                    "securely and only accessible by the authenticated user.",
                    style: TextStyle(fontSize: 16, color: ttextColor2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "4. User Control and Consent",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Users have control over their data, including the ability to delete "
                    "their account and associated information. By using the app, users agree "
                    "to this Privacy Policy, ensuring responsible data handling in alignment "
                    "with user expectations.",
                    style: TextStyle(fontSize: 16, color: ttextColor2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "5. Policy Updates",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Any updates to this policy will be reflected in-app, and users are "
                    "encouraged to review them. Continued use of the application following "
                    "changes signifies acceptance of the updated policy.",
                    style: TextStyle(fontSize: 16, color: ttextColor2),
                  ),
                  SizedBox(height: 16),
                  Divider(color: tPrimaryColor),
                  SizedBox(height: 16),
                  Text(
                    "This Privacy Policy is designed to ensure transparency and trust, "
                    "reflecting our commitment to protecting user privacy and data integrity.",
                    style: TextStyle(
                      fontSize: 16,
                      color: ttextColor2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: tmediumspace(context)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
