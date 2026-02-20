import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../models/extracted_text_model.dart';

enum ExtractionMode { text, qr }

class TextExtractorController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
    final BarcodeScanner _barcodeScanner = BarcodeScanner(
  formats: [
    BarcodeFormat.aztec,
    BarcodeFormat.code128,
    BarcodeFormat.code39,
    BarcodeFormat.code93,
    BarcodeFormat.codabar,
    BarcodeFormat.dataMatrix,
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.itf,
    BarcodeFormat.pdf417,
    BarcodeFormat.qrCode,
  ],
);

  // Observables (state)
  final RxBool isLoading = false.obs;
  final Rx<ExtractedTextModel?> extracted = Rx<ExtractedTextModel?>(null);
  final RxString errorMessage = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isSupported = (!kIsWeb).obs; // ML Kit not supported on web here
  final Rx<ExtractionMode> extractionMode = ExtractionMode.text.obs;

  @override
  void onClose() {
    _textRecognizer.close();
    _barcodeScanner.close();
    super.onClose();
  }

  void setExtractionMode(ExtractionMode mode) {
    extractionMode.value = mode;
    clear();
  }

  Future<void> scanFromCamera() async {
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
      await _processImage(photo.path, mode: extractionMode.value);
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
    }
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
      await _processImage(photo.path, mode: extractionMode.value);
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
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);

      if (image == null) {
        errorMessage.value = 'No image selected.';
        return;
      }

      selectedImage.value = File(image.path);
      await _processImage(image.path, mode: extractionMode.value);
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
    }
  }

  Future<void> _processImage(String path, {ExtractionMode? mode}) async {
    isLoading.value = true;
    extracted.value = null;
    try {
      final inputImage = InputImage.fromFilePath(path);
      if ((mode ?? extractionMode.value) == ExtractionMode.qr) {
        final List<Barcode> barcodes =
            await _barcodeScanner.processImage(inputImage);
        if (barcodes.isEmpty) {
          errorMessage.value = 'No QR/Barcode found in the image.';
        } else {
          // For demo, show all barcode values joined
          final text = barcodes
              .map((b) => b.displayValue ?? b.rawValue ?? '')
              .where((s) => s.isNotEmpty)
              .join('\n');
          if (text.isEmpty) {
            errorMessage.value = 'No readable QR/Barcode data.';
          } else {
            extracted.value = ExtractedTextModel(text: text);
          }
        }
      } else {
        final RecognizedText recognizedText =
            await _textRecognizer.processImage(inputImage);
        final model = ExtractedTextModel(text: recognizedText.text.trim());
        if (!model.hasText) {
          errorMessage.value = 'No text found in the image.';
        } else {
          extracted.value = model;
        }
      }
    } catch (e) {
      errorMessage.value = 'Error while extracting: $e';
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
