import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_2/controller/image_enhance.dart';
import 'package:task_2/screens/image%20Enhance/widgets/bottom_button.dart';
import 'package:task_2/screens/image%20Enhance/widgets/image_container.dart';

class ImageEnhancement extends StatefulWidget {
  @override
  _ImageEnhancementState createState() => _ImageEnhancementState();
}

class _ImageEnhancementState extends State<ImageEnhancement> {
  final imageEnhanceController = Get.find<ImageEnhanceController>();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: imageEnhanceController.isLoading.value == true ? false : true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Center image and button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      // image
                      ImageContainer(),
                      // spacing
                      SizedBox(height: Get.height / 20),
                      // bottom Button
                      BottomButton(),
                    ],
                  ),
                ),
              ),
              // back Button
              imageEnhanceController.isLoading.value == true
                  ? SizedBox.shrink()
                  : Positioned(
                      top: Get.height / 27,
                      left: Get.width / 30,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
