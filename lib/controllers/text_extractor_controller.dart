import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/extracted_text_model.dart';

class TextExtractorController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  // Observables (state)
  final RxBool isLoading = false.obs;
  final Rx<ExtractedTextModel?> extracted = Rx<ExtractedTextModel?>(null);
  final RxString errorMessage = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isSupported = (!kIsWeb).obs; // ML Kit not supported on web here

  @override
  void onClose() {
    _textRecognizer.close();
    super.onClose();
  }

  Future<void> pickImageFromCamera() async {
    if (!isSupported.value) {
      errorMessage.value = 'This feature is not supported on web.';
      return;
    }

    _resetResult();

    try {
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

      if (photo == null) {
        errorMessage.value = 'No image selected.';
        return;
      }

      selectedImage.value = File(photo.path);
      await _processImage(photo.path);
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
    }
  }

  Future<void> pickImageFromGallery() async {
    if (!isSupported.value) {
      errorMessage.value = 'This feature is not supported on web.';
      return;
    }

    _resetResult();

    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (image == null) {
        errorMessage.value = 'No image selected.';
        return;
      }

      selectedImage.value = File(image.path);
      await _processImage(image.path);
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
    }
  }

  Future<void> _processImage(String path) async {
    isLoading.value = true;
    extracted.value = null;

    try {
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final model =
          ExtractedTextModel(text: recognizedText.text.trim());

      if (!model.hasText) {
        errorMessage.value = 'No text found in the image.';
      } else {
        extracted.value = model;
      }
    } catch (e) {
      errorMessage.value = 'Error while extracting text: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    selectedImage.value = null;
    extracted.value = null;
    errorMessage.value = '';
  }

  void _resetResult() {
    extracted.value = null;
    errorMessage.value = '';
  }
}

