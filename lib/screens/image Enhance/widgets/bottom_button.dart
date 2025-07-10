import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_2/controller/image_enhance.dart';

class BottomButton extends StatelessWidget {
  const BottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final imageEnhanceController = Get.find<ImageEnhanceController>();
    return Obx(() => imageEnhanceController.enhancedImage.value == ""
        ? !imageEnhanceController.isLoading.value
            ? SizedBox(
                width: Get.width * 0.37,
                child: ElevatedButton(
                  onPressed: () => imageEnhanceController.enhanceImage(),
                  child: Row(
                    children: [
                      Text(
                        'Enhance',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      SizedBox(width: Get.height / 150),
                      Icon(Icons.auto_awesome)
                    ],
                  ),
                ),
              )
            : SizedBox.square()
        : imageEnhanceController.isLoading.value
            ? SizedBox.shrink()
            : SizedBox(
                width: Get.width * 0.30,
                child: ElevatedButton(
                  onPressed: () => imageEnhanceController.downloadLoading.value
                      ? null
                      : imageEnhanceController.saveImageToGallery(),
                      
                  child: imageEnhanceController.downloadLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Text(
                              'Save',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            SizedBox(width: Get.height / 150),
                            Icon(Icons.download)
                          ],
                        ),
                ),
              ));
  }
}
