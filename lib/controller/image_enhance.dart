import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:task_2/Data/Network/apiService.dart';
import 'package:task_2/Data/constantKeys.dart';
import 'package:task_2/Model/getModel.dart';
import 'package:task_2/Model/image_upload.dart';
import 'package:task_2/Model/postModel.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
// Updated import to use ONNX service instead of TFLite
import 'package:task_2/data/network/onnx_service.dart';
import 'package:task_2/data/network/connectivity_service.dart';
import 'package:task_2/utils/enum/processing_mode.dart';

class ImageEnhanceController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  RxString enhancedImage = "".obs;
  Rx<XFile?> pickedImage = Rx<XFile?>(null);
  RxDouble value = 0.5.obs;
  RxBool isLoading = false.obs;
  RxBool downloadLoading = false.obs;
  RxBool checkAgain = false.obs;
  RxString requestIdValue = ''.obs;

  Rx<ProcessingMode> processingMode = ProcessingMode.auto.obs;
  RxBool isOfflineModelAvailable = false.obs;
  RxBool isOnline = true.obs;
  RxString processingType = "".obs; // "online" or "offline"

  @override
  void onInit() async {
    super.onInit();

    // Initialize API (keep your existing API initialization)
    ApiKeyManager.init();

    // Try to load ONNX model (assuming model is in assets)
    bool modelLoaded = await ONNXService.loadModel('assets/models/deblur_model.onnx');
    isOfflineModelAvailable.value = modelLoaded;

    // Warm up the model for better first-run performance
    if (modelLoaded) {
      await ONNXService.warmUpModel();
    }

    // Check internet connectivity
    bool hasInternet = await ConnectivityService.hasInternetConnection();
    isOnline.value = hasInternet;

    print('Offline ONNX model available: $modelLoaded');
    print('Internet available: $hasInternet');
  }

  @override
  void onClose() {
    ONNXService.dispose();
    super.onClose();
  }

  void setProcessingMode(ProcessingMode mode) {
    processingMode.value = mode;
    
    switch (mode) {
      case ProcessingMode.online:
        print('Switched to Online mode');
        break;
      case ProcessingMode.offline:
        if (!isOfflineModelAvailable.value) {
          print('Offline ONNX model not available, cannot switch to offline mode');
          Get.snackbar(
            'Error', 
            'Offline ONNX model not available. Please ensure the model is loaded.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        print('Switched to Offline ONNX mode');
        break;
      case ProcessingMode.auto:
        print('Switched to Auto mode');
        break;
    }
    
    debugPrint("Processing mode changed to: ${mode.displayName}");
  }

  // Determine which processing mode to use based on current settings
  Future<ProcessingMode> determineProcessingMode() async {
    switch (processingMode.value) {
      case ProcessingMode.online:
        if (!isOnline.value) {
          throw Exception("Online mode selected but no internet connection");
        }
        return ProcessingMode.online;
        
      case ProcessingMode.offline:
        if (!isOfflineModelAvailable.value) {
          throw Exception("Offline mode selected but ONNX model not available");
        }
        return ProcessingMode.offline;
        
      case ProcessingMode.auto:
        // Auto mode: prefer offline if available, fallback to online
        if (isOfflineModelAvailable.value) {
          return ProcessingMode.offline;
        } else if (isOnline.value) {
          return ProcessingMode.online;
        } else {
          throw Exception("No processing method available");
        }
    }
  }

  // High quality image picking
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 100, // Maximum quality
      maxWidth: null,    // Don't limit dimensions
      maxHeight: null    // Don't limit dimensions
    );

    if (pickedFile != null) {
      isLoading.value = false;
      pickedImage.value = null;
      enhancedImage.value = "";
      pickedImage.value = pickedFile;
      requestIdValue.value = "";
      checkAgain.value = false;
      Get.toNamed('/imageEnhance');
    }
  }

  // Take photo with camera
  Future<void> takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: null,
      maxHeight: null
    );

    if (pickedFile != null) {
      isLoading.value = false;
      pickedImage.value = null;
      enhancedImage.value = "";
      pickedImage.value = pickedFile;
      requestIdValue.value = "";
      checkAgain.value = false;
      Get.toNamed('/imageEnhance');
    }
  }

  // Test different normalization ranges with ONNX
  Future<void> testBothNormalizationRanges() async {
    try {
      isLoading.value = true;
      
      File imageFile = File(pickedImage.value!.path);
      List<File?> results = await ONNXService.testNormalizationRanges(imageFile);
      
      if (results.length >= 2) {
        debugPrint("ONNX test results saved:");
        if (results[0] != null) debugPrint("Range [0,1]: ${results[0]!.path}");
        if (results[1] != null) debugPrint("Range [-1,1]: ${results[1]!.path}");
        
        // Use the first successful result
        File? bestResult = results.firstWhere((r) => r != null, orElse: () => null);
        if (bestResult != null) {
          enhancedImage.value = bestResult.path;
        }
      }
    } catch (e) {
      debugPrint("ONNX testing failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enhanceImage() async {
    if (pickedImage.value == null) {
      _showErrorSnackbar("Please select an image first");
      return;
    }

    try {
      isLoading.value = true;

      ProcessingMode mode = await determineProcessingMode();

      switch (mode) {
        case ProcessingMode.online:
          await enhanceImageOnline();
          break;
        case ProcessingMode.offline:
          await enhanceImageOffline();
          break;
        case ProcessingMode.auto:
          // This should not happen as determineProcessingMode returns specific mode
          break;
      }

      debugPrint("Image enhanced using: ${processingType.value}");
    } catch (e) {
      debugPrint("Enhancement error: $e");

      if (processingType.value == "online" && isOfflineModelAvailable.value) {
        debugPrint("Online failed, trying offline ONNX...");
        try {
          await enhanceImageOffline();
        } catch (offlineError) {
          debugPrint("Both online and offline ONNX failed");
          _showErrorSnackbar("Enhancement failed: $offlineError");
        }
      } else {
        _showErrorSnackbar("Enhancement failed: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enhanceImageOnline() async {
    try {
      processingType.value = "online";

      File imageFile = File(pickedImage.value!.path);

      // Use different preprocessing for online vs offline
      File exifStrippedImage = await stripExifForOnline(imageFile);
      File compressedImage = await compressImageForOnline(exifStrippedImage);
      
      debugPrint("Step1 finish $imageFile");
      
      ImageUploadResponse uploadResponse = await ApiServices.uploadImage(compressedImage);
      
      if (uploadResponse.message == "No more API calls left. Please Upgrade.") {
        debugPrint("upload response ${uploadResponse.message}");
        await ApiKeyManager.moveToNextKey();
        await Future.delayed(Duration(milliseconds: 200));
        await enhanceImageOnline();
        return;
      }

      var postResponse = await ApiServices.postDeblurerRequest(uploadResponse.url!.trim());
      PostResponseModel postModel = PostResponseModel.fromJson(postResponse);

      if (postModel.message == "No more API calls left. Please Upgrade.") {
        debugPrint("post response ${postModel.message}");
        await ApiKeyManager.moveToNextKey();
        await Future.delayed(Duration(milliseconds: 200));
        await enhanceImageOnline();
        return;
      }

      requestIdValue.value = postModel.getRequestId();

      if (postModel.message == null) {
        await Future.delayed(Duration(seconds: 20));
        var getResponse = await ApiServices.getGetApiResponce(postModel.requestId!.trim());
        GetResponseModel getModel = GetResponseModel.fromJson(getResponse);

        if (getModel.message == "No more API calls left. Please Upgrade.") {
          debugPrint("get response ${getModel.message}");
          await ApiKeyManager.moveToNextKey();
          await Future.delayed(Duration(milliseconds: 200));
          await enhanceImageOnline();
          return;
        }

        enhancedImage.value = getModel.output!;
        
        // Show success message
        Get.snackbar(
          'Success',
          'Image enhanced using online API',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Online enhancement error: $e");
      throw e;
    }
  }
  
  // Enhanced offline processing using ONNX
  Future<void> enhanceImageOffline() async {
    try {
      processingType.value = "offline";

      File imageFile = File(pickedImage.value!.path);
      
      // Check original file size
      int fileSizeInBytes = await imageFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      debugPrint("Original file size: ${fileSizeInMB.toStringAsFixed(2)} MB");
      
      // For ONNX, we can handle larger files better than TFLite
      // Apply minimal processing to preserve maximum quality
      File processedImage = imageFile;
      
      // Only process if absolutely necessary (very large files > 50MB)
      if (fileSizeInMB > 50) {
        debugPrint("File very large, applying minimal processing...");
        processedImage = await prepareImageForONNXMinimal(imageFile);
      } else if (fileSizeInMB > 20) {
        // For moderately large files, just strip EXIF
        processedImage = await stripExifOnly(imageFile);
      }

      // Enhance using ONNX Runtime
      File? enhancedFile = await ONNXService.enhanceImageImproved(processedImage);

      if (enhancedFile != null) {
        enhancedImage.value = enhancedFile.path;
        debugPrint("Image enhanced with ONNX successfully");
        
        // Show success message
        Get.snackbar(
          'Success',
          'Image enhanced using offline ONNX model',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception("ONNX offline enhancement failed");
      }
    } catch (e) {
      debugPrint("ONNX offline enhancement error: $e");
      throw e;
    }
  }

  // Minimal processing specifically optimized for ONNX
  Future<File> prepareImageForONNXMinimal(File imageFile) async {
    try {
      // ONNX can handle higher quality inputs better than TFLite
      // So we apply even less compression
      return await stripExifAndMinimalCompression(imageFile);
    } catch (e) {
      debugPrint("Error in ONNX minimal processing: $e");
      return imageFile;
    }
  }

  // Very light compression for ONNX processing
  Future<File> stripExifAndMinimalCompression(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) return file;

      // For ONNX, we can use higher quality settings
      final encodedBytes = img.encodePng(decodedImage, level: 1); // Minimal compression
      final newFile = File('${file.parent.path}/onnx_ready_${DateTime.now().millisecondsSinceEpoch}.png');
      return await newFile.writeAsBytes(encodedBytes);
    } catch (e) {
      debugPrint("ONNX preparation failed: $e");
      return file;
    }
  }

  // Strip EXIF without re-encoding when possible
  Future<File> stripExifOnly(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) return file;

      // Use PNG to avoid any compression artifacts
      final encodedBytes = img.encodePng(decodedImage, level: 0); // No compression
      final newFile = File('${file.parent.path}/no_exif_${DateTime.now().millisecondsSinceEpoch}.png');
      return await newFile.writeAsBytes(encodedBytes);
    } catch (e) {
      debugPrint("EXIF stripping failed: $e");
      return file;
    }
  }

  // Compression for online processing (can be more aggressive)
  Future<File> compressImageForOnline(File imageFile) async {
    try {
      String extension = path.extension(imageFile.path).toLowerCase();
      CompressFormat format = CompressFormat.jpeg;
      String targetExtension = '.jpg';

      if (extension == '.png') {
        format = CompressFormat.png;
        targetExtension = '.png';
      }

      Directory tempDir = await getTemporaryDirectory();
      String targetPath = '${tempDir.path}/compressed_online_image$targetExtension';

      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 85, // Higher quality for online
        format: format,
      );

      if (result == null) throw Exception("Image compression failed");
      return File(result.path);
    } catch (e) {
      throw Exception("Error during online image compression: $e");
    }
  }

  // Keep original method for online processing
  Future<File> stripExifForOnline(File file) async {
    final bytes = await file.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return file;

    final encodedBytes = img.encodeJpg(decodedImage, quality: 90);
    final newFile = File('${file.parent.path}/no_exif_online_${DateTime.now().millisecondsSinceEpoch}.jpg');
    return await newFile.writeAsBytes(encodedBytes);
  }

  // Save enhanced image to gallery
  Future<void> saveImageToGallery() async {
    try {
      downloadLoading.value = true;

      if (enhancedImage.value == "") {
        Get.snackbar('Error', 'No image to save');
        return;
      }

      final PermissionStatus status = await Permission.photos.request();

      if (status.isGranted) {
        Uint8List bytes;

        if (processingType.value == "online") {
          // Download from URL for online processed images
          final response = await http.get(Uri.parse(enhancedImage.value));
          if (response.statusCode == 200) {
            bytes = response.bodyBytes;
          } else {
            throw Exception('Failed to download image from URL');
          }
        } else {
          // Read from local file for offline processed images
          File enhancedFile = File(enhancedImage.value);
          if (await enhancedFile.exists()) {
            bytes = await enhancedFile.readAsBytes();
          } else {
            throw Exception('Enhanced image file not found');
          }
        }

        // Save to gallery
        final result = await SaverGallery.saveImage(
          bytes,
          quality: 95,
          fileName: "enhanced_image_${DateTime.now().millisecondsSinceEpoch}.jpg",
          androidRelativePath: "Pictures/EnhancedImages",
          skipIfExists: false,
        );

        if (result.isSuccess) {
          Get.snackbar(
            'Success',
            'Image saved to gallery successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception('Failed to save image to gallery');
        }
      } else {
        Get.snackbar(
          'Permission Denied',
          'Please grant storage permission to save images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error saving image: $e");
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      downloadLoading.value = false;
    }
  }

  // Share enhanced image
  Future<void> shareImage() async {
    try {
      if (enhancedImage.value == "") {
        Get.snackbar('Error', 'No image to share');
        return;
      }

      File imageFile;
      
      if (processingType.value == "online") {
        // Download and create temporary file for online images
        final response = await http.get(Uri.parse(enhancedImage.value));
        if (response.statusCode == 200) {
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = '${tempDir.path}/temp_share_image.jpg';
          imageFile = File(tempPath);
          await imageFile.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download image');
        }
      } else {
        // Use local file for offline images
        imageFile = File(enhancedImage.value);
      }

      if (await imageFile.exists()) {
        // You can implement sharing functionality here
        // For example, using share_plus package
        debugPrint("Image ready for sharing: ${imageFile.path}");
        Get.snackbar(
          'Info',
          'Image ready for sharing',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Image file not found');
      }
    } catch (e) {
      debugPrint("Error sharing image: $e");
      Get.snackbar(
        'Error',
        'Failed to prepare image for sharing: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Retry enhancement with different method
  Future<void> retryEnhancement() async {
    if (processingType.value == "online" && isOfflineModelAvailable.value) {
      // Try offline if online failed
      try {
        await enhanceImageOffline();
      } catch (e) {
        _showErrorSnackbar("Retry failed: $e");
      }
    } else if (processingType.value == "offline" && isOnline.value) {
      // Try online if offline failed
      try {
        await enhanceImageOnline();
      } catch (e) {
        _showErrorSnackbar("Retry failed: $e");
      }
    } else {
      _showErrorSnackbar("No alternative processing method available");
    }
  }

  // Clear current image and reset state
  void clearImage() {
    pickedImage.value = null;
    enhancedImage.value = "";
    requestIdValue.value = "";
    processingType.value = "";
    checkAgain.value = false;
    isLoading.value = false;
    Get.back();
  }

  // Check processing status for online requests
  Future<void> checkProcessingStatus() async {
    if (requestIdValue.value.isEmpty) {
      _showErrorSnackbar("No request ID available");
      return;
    }

    try {
      checkAgain.value = true;
      
      var getResponse = await ApiServices.getGetApiResponce(requestIdValue.value.trim());
      GetResponseModel getModel = GetResponseModel.fromJson(getResponse);

      if (getModel.message == "No more API calls left. Please Upgrade.") {
        debugPrint("get response ${getModel.message}");
        await ApiKeyManager.moveToNextKey();
        await Future.delayed(Duration(milliseconds: 200));
        await checkProcessingStatus();
        return;
      }

      if (getModel.output != null && getModel.output!.isNotEmpty) {
        enhancedImage.value = getModel.output!;
        Get.snackbar(
          'Success',
          'Image processing completed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Processing',
          'Image is still being processed. Please wait...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error checking status: $e");
      _showErrorSnackbar("Failed to check processing status: $e");
    } finally {
      checkAgain.value = false;
    }
  }

  // Refresh connectivity status
  Future<void> refreshConnectivity() async {
    bool hasInternet = await ConnectivityService.hasInternetConnection();
    isOnline.value = hasInternet;
    
    Get.snackbar(
      'Connectivity',
      hasInternet ? 'Internet connection available' : 'No internet connection',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: hasInternet ? Colors.green : Colors.red,
      colorText: Colors.white,
    );
  }

  // Reload ONNX model
  Future<void> reloadONNXModel() async {
    try {
      bool modelLoaded = await ONNXService.loadModel('assets/models/deblur_model.onnx');
      isOfflineModelAvailable.value = modelLoaded;
      
      if (modelLoaded) {
        await ONNXService.warmUpModel();
      }
      
      Get.snackbar(
        'Model Status',
        modelLoaded ? 'ONNX model loaded successfully' : 'Failed to load ONNX model',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: modelLoaded ? Colors.green : Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Error reloading ONNX model: $e");
      _showErrorSnackbar("Failed to reload ONNX model: $e");
    }
  }

  // Helper method to show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  // Helper method to show success snackbar

  // Get current processing mode display name
  String get currentProcessingModeDisplay {
    switch (processingMode.value) {
      case ProcessingMode.online:
        return "Online";
      case ProcessingMode.offline:
        return "Offline (ONNX)";
      case ProcessingMode.auto:
        return "Auto";
    }
  }

  // Get status information
  Map<String, dynamic> get statusInfo {
    return {
      'processingMode': currentProcessingModeDisplay,
      'isOnline': isOnline.value,
      'isOfflineModelAvailable': isOfflineModelAvailable.value,
      'hasImage': pickedImage.value != null,
      'hasEnhancedImage': enhancedImage.value.isNotEmpty,
      'isLoading': isLoading.value,
      'processingType': processingType.value,
    };
  }
}