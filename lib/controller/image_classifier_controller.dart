import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ImageClassifierController extends GetxController {
  static const model_path =
      'assets/model/lite-model_mobilenet_v1_100_224_uint8_1.tflite';

  static const model_labels = 'assets/model/labels.txt';

  Rx<File?> imageFile = Rxn();
  Rx<bool> isWorking = false.obs;
  RxMap<String, int> results = RxMap();

  late Interpreter _interpreter;
  late List<String> _labels;

  @override
  void onInit() async {
    isWorking.value = true;
    debugPrint("Initialize the interpreter..");
    InterpreterOptions options = InterpreterOptions();
    _interpreter = await Interpreter.fromAsset(model_path, options: options);
    debugPrint("Interpreter ready..");
    debugPrint("Loading labels...");
    String bundle = await rootBundle.loadString(model_labels);
    _labels = bundle.split('\n');
    debugPrint("Labels loaded");
    isWorking.value = false;
    super.onInit();
  }

  void runClassification() {
    results.clear();
    debugPrint("Get labels...");
    isWorking.value = true;
    // Resize the image to fit into the model 224 x 224
    final bytes = imageFile.value!.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);

    img.Image resizedImage = img.copyResize(image!, width: 224, height: 224);
    debugPrint("Image resized");

    final imageMatrix = List.generate(
      224,
      (y) => List.generate(
        224,
        (x) {
          // Get pixel at x,y
          img.Pixel pixel = resizedImage.getPixel(x, y);
          // Build a 3 vector
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    final input = [imageMatrix];

    // Output result: [1, [1001,0]]
    final output = [List<int>.filled(1001, 0)];

    debugPrint("Run classification...");
    _interpreter.run(input, output);

    final result = output.first;
    isWorking.value = false;

    for (int i = 0; i < result.length; i++) {
      if (result[i] > 60) {
        results[_labels[i]] = result[i];
      }
    }
    results.refresh();
  }
}
