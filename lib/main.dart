import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_2/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
// Update By Muhammad Saad Khan
// LinkedIn: /saadkhan960
// GitHub: /saadkhan960
// Email: sk0663812@gmail.com
// Phone-No: 03360361917
// Debult API: https://docs.api.market/api-product-docs/magicapi/deblurer-api