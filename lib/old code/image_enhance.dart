// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:get/get.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:saver_gallery/saver_gallery.dart';
// import 'package:task_2/Data/Network/apiService.dart';
// import 'package:task_2/Data/constantKeys.dart';
// import 'package:task_2/Model/getModel.dart';
// import 'package:task_2/Model/image_upload.dart';
// import 'package:task_2/Model/postModel.dart';
// import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;

// class ImageEnhanceController extends GetxController {
//   final ImagePicker _picker = ImagePicker();
//   RxString enhancedImage = "".obs;
//   Rx<XFile?> pickedImage = Rx<XFile?>(null);
//   RxDouble value = 0.5.obs;
//   RxBool isLoading = false.obs;
//   RxBool downloadLoading = false.obs;
//   RxBool checkAgain = false.obs;
//   RxString requestIdValue = ''.obs;
//   // ------Functions----

//   @override
//   void onInit() {
//     super.onInit();
//     ApiKeyManager.init();
//   }

//   // Pick an image from gallery
//   Future<void> pickImage() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

//     if (pickedFile != null) {
//       isLoading.value = false;
//       pickedImage.value = null;
//       enhancedImage.value = "";
//       pickedImage.value = pickedFile;
//       requestIdValue.value = "";
//       checkAgain.value = false;
//       Get.toNamed('/imageEnhance');
//     }
//   }

//   Future<void> enchanceImage() async {
//     try {
//       isLoading.value = true;

//       // // Convert XFile to File
//       // File imageFile = File(pickedImage.value!.path);

//       // // Compress the image
//       // File compressedImage = await compressImage(imageFile);
//       // debugPrint("Step1 fimnish $imageFile");
//       // Convert XFile to File
//       File imageFile = File(pickedImage.value!.path);

//       // Step: Remove EXIF
//       File exifStrippedImage = await stripExif(imageFile);

//       // Step: Compress
//       File compressedImage = await compressImage(exifStrippedImage);
//       debugPrint("Step1 fimnish $imageFile");
//       ImageUploadResponse uploadResponse =
//           await ApiServices.uploadImage(compressedImage);
//       if (uploadResponse.message == "No more API calls left. Please Upgrade.") {
//         debugPrint("upload response ${uploadResponse.message}");
//         debugPrint("Stopping function execution due to API limit.");
//         await ApiKeyManager.moveToNextKey();
//         await Future.delayed(Duration(milliseconds: 200));
//         await enchanceImage(); // Retry the function
//         return; // Stop further execution for this call
//       }

//       debugPrint("Step2 fimnish");
//       // ----------------------------------------------------------
//       // Step 3: Send the POST request to the API
//       var postResponse =
//           await ApiServices.postDeblurerRequest(uploadResponse.url!.trim());
//           debugPrint("Raw postResponse: $postResponse");
//       PostResponseModel postModel = PostResponseModel.fromJson(postResponse);
//       debugPrint("id ${postModel.getRequestId()}");
      

//       // Check for the "No more API calls left" message
//       if (postModel.message == "No more API calls left. Please Upgrade.") {
//         debugPrint("post response ${postModel.message}");
//         debugPrint("Stopping function execution due to API limit.");
//         await ApiKeyManager.moveToNextKey();
//         await Future.delayed(Duration(milliseconds: 200));
//         await enchanceImage(); // Retry the function
//         return; // Stop further execution for this call
//       }
//       requestIdValue.value = postModel.getRequestId();
//       debugPrint(
//           "chceking here in enchance method controller: ${requestIdValue.value}");
//       debugPrint("Step3 fimnish");
//       // ----------------------------------------------------------
//       // Step 4: Use the request_id to get the result
//       if (postModel.message == null) {
//         await Future.delayed(Duration(seconds: 60));
//         var getResponse =
//             await ApiServices.getGetApiResponce(postModel.requestId!.trim());

//         GetResponseModel getModel = GetResponseModel.fromJson(getResponse);
//         debugPrint("get api message: ${getModel.message}");
//         debugPrint("get api output: ${getModel.output}");
//         debugPrint("get api status: ${getModel.status}");
//         if (getModel.message == "No more API calls left. Please Upgrade.") {
//           debugPrint("get response ${getModel.message}");
//           debugPrint("Stopping function execution due to API limit.");
//           await ApiKeyManager.moveToNextKey();
//           await Future.delayed(Duration(milliseconds: 200));
//           await enchanceImage(); // Retry the function
//           return; // Stop further execution for this call
//         }
//         debugPrint("Step4 fimnish");

//         debugPrint("Final Result URL: ${getModel.output}");
        
//         debugPrint("again Final Result URL: ${getModel.output}");

//         enhancedImage.value = getModel.output!;
//       }
//     } catch (e) {
//       debugPrint("Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<File> compressImage(File imageFile) async {
//     try {
//       String extension = path.extension(imageFile.path).toLowerCase();

//       CompressFormat format = CompressFormat.jpeg;
//       String targetExtension = '.jpg'; // Default extension for JPEG

//       // Determine the format based on the file extension
//       if (extension == '.png') {
//         format = CompressFormat.png;
//         targetExtension = '.png';
//       } else if (extension == '.jpg' || extension == '.jpeg') {
//         format = CompressFormat.jpeg;
//         targetExtension = '.jpg';
//       } else if (extension == '.webp') {
//         format = CompressFormat.jpeg;
//         targetExtension = '.jpg';
//       } else {
//         throw Exception(
//             "Unsupported file format. Only PNG and JPEG are supported.");
//       }

//       // Get the temporary directory for saving the compressed image
//       Directory tempDir = await getTemporaryDirectory();
//       String targetPath = '${tempDir.path}/compressed_image$targetExtension';

//       // Compress the image
//       var result = await FlutterImageCompress.compressAndGetFile(
//         imageFile.absolute.path,
//         targetPath,
//         quality: 20,
//         format: format,
//       );

//       if (result == null) throw Exception("Image compression failed");

//       return File(result.path);
//     } catch (e) {
//       throw Exception("Error during image compression: $e");
//     }
//   }

//   Future<void> saveImageToGallery() async {
//     try {
//       downloadLoading.value = true;

//       if (enhancedImage.value == "") {
//         Get.snackbar('Error', 'No image to save');
//         downloadLoading.value = false;
//         return;
//       }

//       // Request storage or photo library permission
//       final PermissionStatus status = await Permission.photos.request();

//       if (status.isGranted) {
//         // Download the image
//         final response = await http.get(Uri.parse(enhancedImage.value));

//         if (response.statusCode == 200) {
//           // Convert the response body into bytes
//           Uint8List bytes = response.bodyBytes;

//           // Save the image
//           final result = await SaverGallery.saveImage(
//             bytes,
//             fileName: 'enhanced_image_${DateTime.now().millisecondsSinceEpoch}',
//             skipIfExists: true,
//           );

//           if (result.isSuccess) {
//             Get.snackbar(
//               'Success',
//               'Image saved to gallery',
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//             );
//           } else {
//             Get.snackbar(
//               'Error',
//               'Failed to save image',
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.red,
//               colorText: Colors.white,
//             );
//           }
//         } else {
//           Get.snackbar(
//             'Error',
//             'Failed to download image',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//         }
//       } else if (status.isDenied) {
//         Get.snackbar(
//           'Permission Denied',
//           'Storage permission is required to save the image',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       } else if (status.isPermanentlyDenied) {
//         Get.snackbar(
//           'Permission Denied',
//           'Permission permanently denied. Enable it in settings.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         await openAppSettings();
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred while saving the image: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       downloadLoading.value = false;
//     }
//   }

//   static Future<File> stripExif(File file) async {
//   final bytes = await file.readAsBytes();
//   final decodedImage = img.decodeImage(bytes);
//   if (decodedImage == null) return file;

//   final encodedBytes = img.encodeJpg(decodedImage); // Re-encodes without EXIF
//   final newFile = File('${file.parent.path}/no_exif.jpg');
//   return await newFile.writeAsBytes(encodedBytes);
// }
// }
//   // Future<void> checkImageResponceAgain() async {
//   //   try {
//   //     isLoading.value = true;

//   //     // Step 4: Use the request_id to get the result
//   //     var getResponse = await ApiServices.checkGetResponceAgain();
//   //     GetResponseModel getModel = GetResponseModel.fromJson(getResponse);
//   //     if (getModel.message == "No more API calls left. Please Upgrade.") {
//   //       debugPrint("get response ${getModel.message}");
//   //       debugPrint("Stopping function execution due to API limit.");
//   //       await ApiKeyManager.moveToNextKey();
//   //       await Future.delayed(Duration(milliseconds: 200));
//   //       await enchanceImage(); // Retry the function
//   //       return; // Stop further execution for this call
//   //     }
//   //     debugPrint("Final Result URL: ${getModel.result}");

//   //     enhancedImage.value = getModel.result!;
//   //   } catch (e) {
//   //     debugPrint("Error: $e");
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }
