// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:task_2/Data/app_exception.dart';
// import 'package:task_2/Data/constantKeys.dart';
// import 'package:task_2/Model/image_upload.dart';
// import 'package:path/path.dart' as path;
// import 'package:task_2/controller/image_enhance.dart';

// class ApiServices {
//   static final imageEnhanceController = Get.find<ImageEnhanceController>();
//   static final postResponce = '';
//   static Future<ImageUploadResponse> uploadImage(File imageFile) async {
//     const String apiUrl =
//         'https://api.magicapi.dev/api/v1/magicapi/image-upload/upload';

//     try {
//       // Get file extension to determine mime type
//       String extension = path.extension(imageFile.path).toLowerCase();
//       String mimeType = 'jpeg';

//       // Set mimeType based on file extension
//       if (extension == '.png') {
//         mimeType = 'png';
//       } else if (extension == '.jpg' || extension == '.jpeg') {
//         mimeType = 'jpeg';
//       }

//       debugPrint("Uploading ${imageFile.path} with MIME type: $mimeType");

//       var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
//         ..headers.addAll({
//           'accept': 'application/json',
//           'x-magicapi-key': ApiKeyManager.currentApiKey,
//         })
//         ..files.add(await http.MultipartFile.fromPath(
//           'filename',
//           imageFile.path,
//           contentType: MediaType('image', mimeType),
//         ));

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       var finalResponse = returnResponse(response);
//       debugPrint("Upload Image Response: $finalResponse");
//       return ImageUploadResponse.fromJson(finalResponse);
//     } catch (e) {
//       Get.closeCurrentSnackbar();
//       Get.snackbar(
//         'Error',
//         'Something Went Wrong try again. or try diffrent image',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       throw Exception('Error uploading image: $e');
//     }
//   }

//   static Future<dynamic> postDeblurerRequest(String imageUrl) async {
//     dynamic jsonData;
//     try {
//       const String postApiUrl =
//           "https://api.magicapi.dev/api/v1/magicapi/deblurer/deblurer";
//       Map<String, String> headers = {
//         'accept': 'application/json',
//         'x-magicapi-key': ApiKeyManager.currentApiKey, // API key
//         'Content-Type': 'application/json'
//       };
//       Map<String, dynamic> body = {
//         "image": imageUrl,
//         "task_type": "Image Debluring (REDS)"
//       };

//       var response = await http
//           .post(
//         Uri.parse(postApiUrl),
//         headers: headers,
//         body: jsonEncode(body),
//       )
//           .timeout(const Duration(seconds: 20), onTimeout: () {
//         throw RequestTimeOut("Request Timeout");
//       });

//       jsonData = returnResponse(response);
//     } on SocketException {
//       throw InternetException("No Internet Connection");
//     } on RequestTimeOut {
//       throw RequestTimeOut("Request Timeout");
//     } catch (e) {
//       debugPrint("check error here: ${e.toString()}");
//       if (e.toString().contains(
//           "No more API calls left. Please Upgrade: 429Failed To Fetch Data From The Server")) {
//         // Move to the next API key and retry
//         await ApiKeyManager.moveToNextKey();
//         debugPrint("Switching to next API key: ${ApiKeyManager.currentApiKey}");
//       }
//       Get.closeAllSnackbars();
//       Get.snackbar(
//         'Error',
//         'Something Went Wrong try again later. or try diffrent image',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//     return jsonData;
//   }

//   static Future getGetApiResponce(String requestId) async {
//     dynamic jsonData;
//     try {
//       String getApiUrl =
//           "https://api.magicapi.dev/api/v1/magicapi/deblurer/predictions/$requestId";
//       Map<String, String> headers = {
//         'accept': 'application/json',
//         'x-magicapi-key': ApiKeyManager.currentApiKey, // API key
//       };
//       while (true) {
//         // Loop to keep checking the status
//         var response = await http
//             .get(Uri.parse(getApiUrl), headers: headers)
//             .timeout(const Duration(seconds: 50), onTimeout: () {
//           throw RequestTimeOut("");
//         });

//         // if (response.statusCode == 200) {
//         //   // Success response
//         //   imageEnhanceController.checkAgain.value = false;
//         //   Get.closeCurrentSnackbar();
//         //   Get.snackbar(
//         //     'Success',
//         //     'Image Enhanced Successfully',
//         //     snackPosition: SnackPosition.BOTTOM,
//         //     backgroundColor: Colors.greenAccent,
//         //     colorText: Colors.white,
//         //   );
//         //   jsonData = returnResponse(response);
//         //   break; // Exit the loop if status is 200
//         // } 
//         if (response.statusCode == 200) {
//             jsonData = returnResponse(response);
//             var output = jsonData['output'];
//             debugPrint("output: $output");
//             print("output: $output");

//             if (output != null) {
//               print("output kay ander agaya huai : $output");
//               imageEnhanceController.checkAgain.value = false;
//               Get.closeCurrentSnackbar();
//               Get.snackbar(
//                 'Success',
//                 'Image Enhanced Successfully',
//                 snackPosition: SnackPosition.BOTTOM,
//                 backgroundColor: Colors.greenAccent,
//                 colorText: Colors.white,
//               );
//               break;
//             } else {
//               debugPrint("200 OK but output is null.");
//             }
//           }

//         else if (response.statusCode == 201) {
//           // Processing state, wait and retry
//           debugPrint("Image is still processing. Retrying in 25 seconds...");
//           await Future.delayed(const Duration(seconds: 25));
//         } else {
//           // Handle other errors
//           // jsonData = handleErrorResponse(response);
//           jsonData = returnResponse(response);
//           break; // Exit the loop on any other status
//         }
//       }
//     } on SocketException {
//       throw InternetException("No Internet Connection ");
//     } on RequestTimeOut {
//       throw RequestTimeOut('Request Timeout ');
//     } catch (e) {
//       debugPrint("enchance image requestcoed:${e} ");
//       if (e.toString().trim() !=
//           "too much time 201: 201Failed To Fetch Data From The Server") {
//         Get.closeCurrentSnackbar();
//         Get.snackbar(
//           'Error',
//           'Something Went Wrong try again later. or try diffrent image',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//       if (e.toString().contains(
//           "No more API calls left. Please Upgrade: 429Failed To Fetch Data From The Server")) {
//         // Move to the next API key and retry
//         await ApiKeyManager.moveToNextKey();
//         debugPrint("Switching to next API key: ${ApiKeyManager.currentApiKey}");
//       }
//     }
//     return jsonData;
//   }

//   static dynamic returnResponse(http.Response response) {
//     switch (response.statusCode) {
//       case 200:
//       case 202:
//       case 204:
//         dynamic jsonResponse = jsonDecode(response.body);
//         debugPrint("jsonResponse in apiservices: $jsonResponse");
//         return jsonResponse;

//       case 201:
//         // Get.closeAllSnackbars();
//         imageEnhanceController.checkAgain.value = true;
//         Get.snackbar(
//           'Taking to much time',
//           'Image take too much time to enhace try again later',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.amber,
//           colorText: Colors.white,
//         );
//         throw FetchDataException('too much time 201: ${response.statusCode}');
//       case 400:
//         throw InvalidUrlException('Bad Request: ${response.statusCode}');

//       case 401:
//       case 403:
//         Get.closeAllSnackbars();
//         Get.snackbar(
//           'Network Error',
//           'Check your internet connection',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         throw InternetException(
//             'Unauthorized/Forbidden: ${response.statusCode}');

//       case 404:
//         throw FetchDataException('Not Found: ${response.statusCode}');

//       case 408:
//         Get.closeAllSnackbars();
//         Get.snackbar(
//           'Network Error',
//           'Check your internet connection',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         throw RequestTimeOut('Request Timeout: ${response.statusCode}');
//       case 429:
//         dynamic jsonResponse = jsonDecode(response.body);
//         return jsonResponse;
//       case 500:
//       case 502:
//       case 503:
//       case 504:
//         Get.closeAllSnackbars();
//         Get.snackbar(
//           'Server Error',
//           'Something went wrong. Please try again later, or try a different image.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         throw ServerError(
//             'Server Error: ${response.statusCode} - ${response.reasonPhrase}');

//       default:
//         throw FetchDataException(
//             'Unexpected Error: ${response.statusCode} - ${response.reasonPhrase}');
//     }
//   }
// }
//   // static Future checkGetResponceAgain() async {
//   //   dynamic jsonData;
//   //   try {
//   //     String getApiUrl =
//   //         "https://api.magicapi.dev/api/v1/magicapi/deblurer/predictions/${imageEnhanceController.requestIdValue.value}";
//   //     Map<String, String> headers = {
//   //       'accept': 'application/json',
//   //       'x-magicapi-key': ApiKeyManager.currentApiKey, // API key
//   //     };
//   //     var responce = await http
//   //         .get(Uri.parse(getApiUrl), headers: headers)
//   //         .timeout(const Duration(seconds: 10), onTimeout: () {
//   //       throw RequestTimeOut("");
//   //     });
//   //     if (responce.statusCode == 200) {
//   //       imageEnhanceController.checkAgain.value = false;
//   //       Get.closeCurrentSnackbar();
//   //       Get.snackbar(
//   //         'Success',
//   //         'Image Enchance Successfully',
//   //         snackPosition: SnackPosition.BOTTOM,
//   //         backgroundColor: Colors.greenAccent,
//   //         colorText: Colors.white,
//   //       );
//   //     }
//   //     jsonData = returnResponse(responce);
//   //     debugPrint("enchance image requestcoed:${responce} ");
//   //   } on SocketException {
//   //     throw InternetException("No Internet Connection ");
//   //   } on RequestTimeOut {
//   //     throw RequestTimeOut('Request Timeout ');
//   //   } catch (e) {
//   //     debugPrint("enchance image requestcoed:${e} ");
//   //     if (e.toString().trim() !=
//   //         "too much time 201: 201Failed To Fetch Data From The Server") {
//   //       Get.closeCurrentSnackbar();
//   //       Get.snackbar(
//   //         'Error',
//   //         'Something Went Wrong try again later. or try diffrent image',
//   //         snackPosition: SnackPosition.BOTTOM,
//   //         backgroundColor: Colors.red,
//   //         colorText: Colors.white,
//   //       );
//   //     }
//   //     if (e.toString().contains(
//   //         "No more API calls left. Please Upgrade: 429Failed To Fetch Data From The Server")) {
//   //       // Move to the next API key and retry
//   //       await ApiKeyManager.moveToNextKey();
//   //       debugPrint("Switching to next API key: ${ApiKeyManager.currentApiKey}");
//   //     }
//   //   }
//   //   return jsonData;
//   // }

//   // var responce = await http
//       //     .get(Uri.parse(getApiUrl), headers: headers)
//       //     .timeout(const Duration(seconds: 20), onTimeout: () {
//       //   throw RequestTimeOut("");
//       // });
//       // if (responce.statusCode == 200) {
//       //   imageEnhanceController.checkAgain.value = false;
//       //   Get.closeCurrentSnackbar();
//       //   Get.snackbar(
//       //     'Success',
//       //     'Image Enchance Successfully',
//       //     snackPosition: SnackPosition.BOTTOM,
//       //     backgroundColor: Colors.greenAccent,
//       //     colorText: Colors.white,
//       //   );
//       // }
//       // jsonData = returnResponse(responce);
//       // debugPrint("enchance image requestcoed:${responce} ");