import 'dart:io';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ONNXService {
  static OrtSession? _session;
  static bool _isModelLoaded = false;
  static bool _modelExpectsMinusOneToOne = false; // Set based on your model
  static OrtRunOptions? _runOptions;

  static Future<bool> loadModel(String s) async {
    try {
      // Initialize ONNX Runtime
      OrtEnv.instance.init();
      
      // Load model from assets
      final modelAssetPath = 'models/deblur_model.onnx';
      final modelBytes = await rootBundle.load(modelAssetPath);
      final modelData = modelBytes.buffer.asUint8List();
      
      // Create session options
      final sessionOptions = OrtSessionOptions();
      
      // Try to use GPU if available
      try {
        
        print('Using CPU execution provider');
      } catch (e) {
        print('GPU/Hardware acceleration not available, using CPU: $e');
      }
      
      // Create session
      _session = OrtSession.fromBuffer(modelData, sessionOptions);
      
      // Create run options
      _runOptions = OrtRunOptions();
      
      _isModelLoaded = true;
      
      // Print model info for debugging
      _printModelInfo();
      
      return true;
    } catch (e) {
      print('Failed to load ONNX model: $e');
      return false;
    }
  }

  static void _printModelInfo() {
    if (_session == null) return;
    
    try {
      var inputNames = _session!.inputNames;
      var outputNames = _session!.outputNames;
      
      print('=== ONNX MODEL INFO ===');
      print('Input names: $inputNames');
      print('Output names: $outputNames');
      
      // Basic model info - the specific typeInfo methods may not be available
      print('Number of inputs: ${inputNames.length}');
      print('Number of outputs: ${outputNames.length}');
      print('=======================');
    } catch (e) {
      print('Error getting model info: $e');
    }
  }

  // Enhanced preprocessing with multiple interpolation options
  static OrtValueTensor preprocessImage(img.Image image, List<int> inputShape) {
    int height = inputShape[1];  // Assuming NCHW or NHWC format
    int width = inputShape[2];
    int channels = inputShape[3];
    
    // Determine if model expects NCHW or NHWC format
    // Assume NHWC if last dimension is 3
    bool isNCHW = inputShape[1] == 3; // Assume NCHW if second dimension is 3
    
    if (isNCHW) {
      channels = inputShape[1];
      height = inputShape[2];
      width = inputShape[3];
    }
    
    print('Input format: ${isNCHW ? "NCHW" : "NHWC"}');
    print('Target size: ${width}x${height}, channels: $channels');
    
    // Resize with high-quality interpolation
    img.Image resizedImage;
    if (image.width != width || image.height != height) {
      resizedImage = img.copyResize(
        image, 
        width: width, 
        height: height,
        interpolation: img.Interpolation.cubic
      );
    } else {
      resizedImage = image;
    }
    
    // Convert to float32 array
    List<double> inputData = [];
    
    if (isNCHW) {
      // NCHW format: [batch, channel, height, width]
      for (int c = 0; c < channels; c++) {
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            img.Pixel pixel = resizedImage.getPixel(x, y);
            double value;
            
            if (c == 0) value = pixel.r.toDouble();
            else if (c == 1) value = pixel.g.toDouble();
            else value = pixel.b.toDouble();
            
            // Normalize based on model expectations
            if (_modelExpectsMinusOneToOne) {
              value = (value / 255.0) * 2.0 - 1.0; // [-1, 1]
            } else {
              value = value / 255.0; // [0, 1]
            }
            
            inputData.add(value);
          }
        }
      }
    } else {
      // NHWC format: [batch, height, width, channel]
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          img.Pixel pixel = resizedImage.getPixel(x, y);
          
          List<double> pixelValues = [
            pixel.r.toDouble(),
            pixel.g.toDouble(), 
            pixel.b.toDouble()
          ];
          
          for (double value in pixelValues) {
            if (_modelExpectsMinusOneToOne) {
              inputData.add((value / 255.0) * 2.0 - 1.0); // [-1, 1]
            } else {
              inputData.add(value / 255.0); // [0, 1]
            }
          }
        }
      }
    }
    
    // Create tensor - using the correct constructor
    return OrtValueTensor.createTensorWithDataList(
      inputData,
      inputShape
    );
  }

  // Enhanced postprocessing with better color handling
  static img.Image postprocessOutput(OrtValue output, List<int> outputShape) {
    int height = outputShape[1];
    int width = outputShape[2]; 
    int channels = outputShape[3];
    
    // Check if output is in NCHW format
    bool isNCHW = outputShape[1] == 3;
    if (isNCHW) {
      channels = outputShape[1];
      height = outputShape[2];
      width = outputShape[3];
    }
    
    List<double> outputData = (output as OrtValueTensor).value as List<double>;
    img.Image processedImage = img.Image(width: width, height: height);
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double r, g, b;
        
        if (isNCHW) {
          // NCHW format
          int rIndex = y * width + x;
          int gIndex = height * width + y * width + x;
          int bIndex = 2 * height * width + y * width + x;
          
          r = outputData[rIndex];
          g = outputData[gIndex];  
          b = outputData[bIndex];
        } else {
          // NHWC format
          int baseIndex = (y * width + x) * channels;
          r = outputData[baseIndex];
          g = outputData[baseIndex + 1];
          b = outputData[baseIndex + 2];
        }
        
        // Convert to [0, 255] range
        if (_modelExpectsMinusOneToOne) {
          r = ((r + 1.0) / 2.0 * 255.0).clamp(0.0, 255.0);
          g = ((g + 1.0) / 2.0 * 255.0).clamp(0.0, 255.0);
          b = ((b + 1.0) / 2.0 * 255.0).clamp(0.0, 255.0);
        } else {
          r = (r * 255.0).clamp(0.0, 255.0);
          g = (g * 255.0).clamp(0.0, 255.0);
          b = (b * 255.0).clamp(0.0, 255.0);
        }
        
        processedImage.setPixel(
          x, y, 
          img.ColorRgb8(r.round(), g.round(), b.round())
        );
      }
    }
    
    return processedImage;
  }

  // Main enhancement method with improved error handling
  static Future<File?> enhanceImageImproved(File inputImageFile) async {
    if (!_isModelLoaded || _session == null) {
      print('ONNX model not loaded');
      return null;
    }

    try {
      Uint8List bytes = await inputImageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        print('Failed to decode input image');
        return null;
      }

      print('Original image size: ${originalImage.width}x${originalImage.height}');

      // Get input shape from model
      String inputName = _session!.inputNames.first;
      
      // Parse shape - this is a simplified approach, you might need to adjust based on your model
      List<int> inputShape = [1, 256, 256, 3]; // Default shape, adjust based on your model
      
      // You can get the actual shape from the model metadata if available
      print('Using input shape: $inputShape');

      // Preprocess image
      OrtValueTensor inputTensor = preprocessImage(originalImage, inputShape);
      
      // Prepare inputs map
      Map<String, OrtValue> inputs = {inputName: inputTensor};

      // Run inference with timing
      var stopwatch = Stopwatch()..start();
      List<OrtValue?>? outputs = await _session!.runAsync(_runOptions!, inputs);
      
      if (outputs == null || outputs.isEmpty) {
        throw Exception('No output from ONNX model');
      }
      
      stopwatch.stop();
      print('ONNX Inference completed in: ${stopwatch.elapsedMilliseconds}ms');

      // Get output shape
      OrtValue output = outputs.first!;
      List<int> outputShape = [1, 256, 256, 3]; // Default, adjust based on your model
      
      // Post-process output
      img.Image enhancedImage = postprocessOutput(output, outputShape);
      
      // Resize back to original dimensions with high quality if needed
      if (originalImage.width != outputShape[2] || originalImage.height != outputShape[1]) {
        print('Resizing from ${outputShape[2]}x${outputShape[1]} to ${originalImage.width}x${originalImage.height}');
        enhancedImage = img.copyResize(
          enhancedImage, 
          width: originalImage.width, 
          height: originalImage.height,
          interpolation: img.Interpolation.cubic
        );
      }

      // Save with maximum quality
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/onnx_enhanced_${DateTime.now().millisecondsSinceEpoch}.png';
      File enhancedFile = File(tempPath);
      
      // Use PNG to avoid compression artifacts
      await enhancedFile.writeAsBytes(img.encodePng(enhancedImage, level: 0));
      
      print('Enhanced image saved to: $tempPath');
      
      // Clean up tensors
      inputTensor.release();
      for (var output in outputs) {
        output?.release();
      }
      
      return enhancedFile;
      
    } catch (e) {
      print('ERROR during ONNX image enhancement: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Test different normalization ranges
  static Future<List<File?>> testNormalizationRanges(File inputImageFile) async {
    if (!_isModelLoaded || _session == null) {
      return [];
    }

    List<File?> results = [];
    
    // Test [0,1] range
    print('Testing [0,1] normalization...');
    _modelExpectsMinusOneToOne = false;
    File? result1 = await enhanceImageImproved(inputImageFile);
    results.add(result1);
    
    // Test [-1,1] range  
    print('Testing [-1,1] normalization...');
    _modelExpectsMinusOneToOne = true;
    File? result2 = await enhanceImageImproved(inputImageFile);
    results.add(result2);
    
    return results;
  }

  // Configuration methods
  static void setNormalizationRange(bool useMinusOneToOne) {
    _modelExpectsMinusOneToOne = useMinusOneToOne;
    print('ONNX normalization range set to: ${useMinusOneToOne ? "[-1,1]" : "[0,1]"}');
  }

  // Performance optimization: Warm up the model
  static Future<void> warmUpModel() async {
    if (!_isModelLoaded || _session == null) return;
    
    try {
      // Create a dummy input to warm up the model
      List<int> inputShape = [1, 256, 256, 3]; // Adjust based on your model
      List<double> dummyData = List.filled(1 * 256 * 256 * 3, 0.5);
      
      OrtValueTensor dummyTensor = OrtValueTensor.createTensorWithDataList(
        dummyData,
        inputShape
      );
      
      String inputName = _session!.inputNames.first;
      Map<String, OrtValue> inputs = {inputName: dummyTensor};
      
      List<OrtValue?>? outputs = await _session!.runAsync(_runOptions!, inputs);
      
      if (outputs == null || outputs.isEmpty) {
        print('Model warm-up failed: No outputs');
        return;
      }
      
      // Clean up
      dummyTensor.release();
      for (var output in outputs) {
        output?.release();
      }
      
      print('ONNX model warmed up successfully');
    } catch (e) {
      print('Model warm-up failed: $e');
    }
  }

  static void dispose() {
    _session?.release();
    _session = null;
    _runOptions?.release();
    _runOptions = null;
    _isModelLoaded = false;
    OrtEnv.instance.release();
  }

  static bool get isModelLoaded => _isModelLoaded;
}