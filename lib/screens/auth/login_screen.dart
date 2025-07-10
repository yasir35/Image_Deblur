import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isButtonEnabled = false;
  bool _isLoading = false;
  TextEditingController _usernamecontroller = new TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordcontroller = new TextEditingController();
  final FirebaseAuthController _auth = FirebaseAuthController();

  @override
  void dispose() {
    _usernamecontroller.dispose();
    _emailController.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _usernamecontroller.addListener(_validateFields);
    _passwordcontroller.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      isButtonEnabled = _usernamecontroller.text.isNotEmpty &&
          _passwordcontroller.text.isNotEmpty;
    });
  }

  void _login() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });

    String username = _usernamecontroller.text;
    String password = _passwordcontroller.text;

    User? user = await _auth.loginWithUsernameAndPassword(username, password);
    setState(() {
      _isLoading = false; // Set loading to false
    });
    if (user != null) {
      Get.snackbar("Successfull", "LoggedIn successfully");
      print("Login successful");
      Get.offAllNamed("/homescreen");
    } else {
      Get.snackbar("Error", "Login failed");
      print("Login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        return SingleChildScrollView(
          child: Container(
            height: screenHeight,
            child: Stack(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight / 2.5,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                        tPrimaryColor,
                        tPrimaryColor.withOpacity(0.4),
                      ])),
                ),
                Container(
                  margin: EdgeInsets.only(top: screenHeight / 3),
                  height: screenHeight / 1.5,
                  width: screenWidth,
                  decoration: BoxDecoration(
                      color: tSecondaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40))),
                  child: Text(""),
                ),
                Positioned(
                  top: screenHeight / 6,
                  left: 0,
                  right: 0, // Center horizontally
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Material(
                          elevation: 8.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 28),
                            width: screenWidth,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formkey,
                                child: Column(
                                  children: [
                                    Text(
                                      "Login",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: tlargefontsize(context),
                                          color: ttextColor),
                                    ),
                                    SizedBox(
                                      height: tverylargespace(context),
                                    ),
                                    _userNameField(),
                                    SizedBox(
                                      height: tmediumspace(context),
                                    ),
                                    _passwordField(),
                                    SizedBox(
                                      height: tsmallspace(context),
                                    ),
                                    showPasswordfield(),
                                    SizedBox(
                                      height: tlargespace(context),
                                    ),
                                    _isLoading
                                        ? CircularProgressIndicator() // Show loading indicator
                                        : _loginButton(context),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: tverylargespace(context),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: tsmallfontsize(context),
                                  color: Colors.black54),
                            ),
                            SizedBox(
                              width: tsmallspace(context),
                            ),
                            GestureDetector(
                                onTap: () {
                                  Get.toNamed("/registerscreen");
                                },
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Row showPasswordfield() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Checkbox(
          value: isPasswordVisible,
          onChanged: (value) {
            setState(() {
              isPasswordVisible = value!;
            });
          },
        ),
        Text("Show Password"),
      ],
    );
  }

  Material _userNameField() {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      borderRadius: BorderRadius.circular(18),
      child: TextFormField(
        controller: _usernamecontroller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Username cannot be empty';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            hintText: 'Username',
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline)),
      ),
    );
  }

  Material _passwordField() {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      borderRadius: BorderRadius.circular(18),
      child: TextFormField(
        controller: _passwordcontroller,
        obscureText: !isPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password cannot be empty';
          } else {
            return null;
          }
        },
        // obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          hintText: 'Password',
          labelText: 'Password',
          prefixIcon: Icon(Icons.lock_outlined),
        ),
      ),
    );
  }

  GestureDetector _loginButton(BuildContext context) {
    return GestureDetector(
      onTap: _login,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: tPrimaryColor, borderRadius: BorderRadius.circular(12)),
          child: Center(
              child: Text(
            "Login",
            style: TextStyle(
                color: ttextColor,
                fontSize: tmediumfontsize(context),
                fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }
}
