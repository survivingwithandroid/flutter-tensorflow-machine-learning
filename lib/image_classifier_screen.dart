import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_picker/controller/image_classifier_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageClassifierScreen extends StatelessWidget {
  ImageClassifierController imageController =
      Get.put(ImageClassifierController());

  ImageClassifierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Machine Learning'),
        elevation: 1.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Center(
          child: _createHome(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt_outlined),
        onPressed: () async {
          final ImagePicker imgPicker = ImagePicker();
          final XFile? image =
              await imgPicker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            imageController.imageFile.value = File(image.path);
            // start recognition
            imageController.runClassification();
          }
        },
      ),
    );
  }

  Widget _createHome(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            child: imageController.imageFile.value == null
                ? const Icon(Icons.image, size: 100)
                : Image.file(imageController.imageFile.value!,
                    fit: BoxFit.scaleDown),
          ),
          Column(
              children: imageController.results.keys.map<Widget>((key) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${key}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 30)),
                SizedBox(
                  width: 5.0,
                ),
                Icon(
                  Icons.circle_rounded,
                  size: 30,
                  color: imageController.results[key]! > 100
                      ? Colors.green
                      : Colors.amber,
                )
              ],
            );
          }).toList()),
        ],
      ),
    );
    ;
  }
}
