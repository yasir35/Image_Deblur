import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';

class FirebaseAuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmailAndPassword(
      String username, String email, String password, File? imageFile) async {
    try {
      // Register user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;

      String? imageBase64;

      if (user != null && imageFile != null) {
        // Compress the image and convert to Base64
        imageBase64 = await _compressAndConvertToBase64(imageFile);
      }

      if (user != null) {
        // Store user data, including image URL, in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'imageBase64': imageBase64,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error during registration: ${e.message}");
      Get.snackbar("Error", "${e.message}");
    } catch (e) {
      print("Error during registration: $e");
      Get.snackbar("Error", "$e");
    }
    return null;
  }

  Future<User?> loginWithUsernameAndPassword(
      String username, String password) async {
    try {
      var userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userQuery.docs.isEmpty) {
        print("No user found with this username.");
        Get.snackbar("Error", "No user found with this username.");
        return null;
      }
      String email = userQuery.docs.first['email'];

      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Error during login: $e");
      Get.snackbar("Error", "Error during login: $e");
    }
    return null;
  }

  Future<String> _compressAndConvertToBase64(File imageFile) async {
    try {
      // Compress the image
      final compressedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 50, // Adjust quality for compression
      );

      if (compressedImage == null) {
        throw Exception("Image compression failed");
      }

      // Convert the compressed image to Base64 string
      return base64Encode(compressedImage);
    } catch (e) {
      print("Error compressing or converting image to Base64: $e");
      throw e;
    }
  }
}
