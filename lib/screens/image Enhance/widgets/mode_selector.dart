import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_2/controller/image_enhance.dart';

import 'package:task_2/utils/enum/processing_mode.dart';


class ModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageEnhanceController>();
    
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mode: ${controller.processingMode.value.displayName}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          PopupMenuButton<ProcessingMode>(
            icon: Icon(Icons.settings, color: Colors.white),
            onSelected: (mode) => controller.setProcessingMode(mode),
            itemBuilder: (context) => ProcessingMode.values.map((mode) {
              bool isAvailable = true;
              if (mode == ProcessingMode.offline) {
                isAvailable = controller.isOfflineModelAvailable.value;
              }
              
              return PopupMenuItem(
                value: mode,
                enabled: isAvailable,
                child: Text(
                  mode.displayName,
                  style: TextStyle(
                    color: isAvailable ? Colors.black : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ));
  }
}