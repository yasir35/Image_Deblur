import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_2/controller/auth_controller.dart';
import 'package:task_2/utils/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formkey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isButtonEnabled = false;
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthController _auth = FirebaseAuthController();
  bool _isLoading = false;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userNameController.addListener(_validateFields);

    _passwordController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      isButtonEnabled = _userNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path); // Update picked image
      });
    }
  }

  void _register() async {
    // setState(() {
    //   _isLoading = true; // Set loading to true
    // });

    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading to true
      });
      String username = _userNameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      User? user = await _auth.registerWithEmailAndPassword(
          username, email, password, _pickedImage);
      setState(() {
        _isLoading = false; // Set loading to false
      });

      if (user != null) {
        Get.snackbar("Successfull", "Registration successfully");
        print("User is successfully created");
        Get.toNamed("/loginscreen");
      }
    } else {
      Get.snackbar("Error", "Registration failed");
      print("Some error occured");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      body: LayoutBuilder(builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        return SingleChildScrollView(
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
              // top: screenHeight / 6,
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.13,
                    ),
                    Material(
                      elevation: 8.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                        width: screenWidth,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Form(
                            key: _formkey,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    "Register",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: tlargefontsize(context),
                                        color: ttextColor),
                                  ),
                                  SizedBox(
                                    height: tverylargespace(context),
                                  ),
                                  picUpload(screenWidth),
                                  SizedBox(height: screenHeight * 0.02),
                                  _userNameField(),
                                  SizedBox(
                                    height: tmediumfontsize(context),
                                  ),
                                  _emailField(),
                                  SizedBox(
                                    height: tmediumfontsize(context),
                                  ),
                                  _passwordField(),
                                  SizedBox(
                                    height: tsmallspace(context),
                                  ),
                                  _showPasswordButton(),
                                  SizedBox(
                                    height: tlargespace(context),
                                  ),
                                  _isLoading
                                      ? CircularProgressIndicator() // Show loading indicator
                                      : _registerButton(context),
                                ],
                              ),
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
                          "Already have an account?",
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
                              Get.offNamed("/loginscreen");
                            },
                            child: Text(
                              "Login",
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
        ));
      }),
    );
  }

  Row _showPasswordButton() {
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

  Stack picUpload(double screenWidth) {
    return Stack(
      children: [
        CircleAvatar(
          radius: screenWidth * 0.18,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!) // Show picked image
              : AssetImage('assets/images/default.png') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Icon(Icons.camera_alt, size: screenWidth * 0.05),
            ),
          ),
        ),
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
        controller: _userNameController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your username';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          hintText: 'Username',
          labelText: 'Username',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
    );
  }

  Material _emailField() {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      borderRadius: BorderRadius.circular(18),
      child: TextFormField(
        controller: _emailController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          // Regular expression to check if email contains "@" and ".com"
          String pattern = r'^[\w-\.]+@([\w-]+\.)+com$';
          RegExp regex = RegExp(pattern);
          if (!regex.hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          hintText: 'Email',
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
      ),
    );
  }

  Material _passwordField() {
    return Material(
      // color: Colors.transparent,
      // elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _passwordController,
            obscureText: !isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              } else if (!RegExp(
                      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$')
                  .hasMatch(value)) {
                return 'Password must contain at least one letter, \none number, and one special character';
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              hintText: 'Password',
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              'Include at least one letter, one number, and one special character.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _registerButton(BuildContext context) {
    return GestureDetector(
      onTap: _register,
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
            "Register",
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
