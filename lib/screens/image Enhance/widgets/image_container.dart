import 'dart:io';
import 'dart:ui';
import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:task_2/controller/image_enhance.dart';

class ImageContainer extends StatelessWidget {
  const ImageContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final imageEnhanceController = Get.find<ImageEnhanceController>();
    return Obx(() => Container(
          width: Get.width,
          height: Get.height * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: imageEnhanceController.enhancedImage.value != "" &&
                  !imageEnhanceController.isLoading.value
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BeforeAfter(
                    height: double.infinity,
                    width: double.infinity,
                    thumbColor: const Color.fromARGB(207, 255, 255, 255),
                    trackColor: const Color.fromARGB(195, 255, 255, 255),
                    value: imageEnhanceController.value.value,
                    before: Image.file(
                      File(imageEnhanceController.pickedImage.value!.path),
                      fit: BoxFit.contain,
                    ),
                    after: imageEnhanceController.processingType.value ==
                            "online"
                        ? Image.network(
                            imageEnhanceController.enhancedImage.value,
                            fit: BoxFit.contain,
                          )
                        : Image.file(
                            File(imageEnhanceController.enhancedImage.value),
                            fit: BoxFit.contain,
                          ),
                    onValueChanged: (newValue) {
                      imageEnhanceController.value.value = newValue;
                    },
                  ),
                )
              : !imageEnhanceController.isLoading.value
                  ? Image.file(
                      File(imageEnhanceController.pickedImage.value!.path),
                      fit: BoxFit.contain,
                    )
                  : Stack(
                      alignment: AlignmentDirectional.center,
                      fit: StackFit.loose,
                      children: [
                        Image.file(
                          File(imageEnhanceController.pickedImage.value!.path),
                          fit: BoxFit.contain,
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/images/loading.json',
                                height: 100, width: 100),
                            Text(
                              "Enhancing",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: Get.width * 0.8,
                              child: Text(
                                textAlign: TextAlign.center,
                                "This may take some time, so please be patient.",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
        ));
  }
}
