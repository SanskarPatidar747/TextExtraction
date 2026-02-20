import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/text_extractor_controller.dart';

class TextExtractorPage extends StatelessWidget {
  const TextExtractorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextExtractorController controller =
        Get.put(TextExtractorController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Text/QR Extractor'),
      ),
      body: kIsWeb
          ? _buildNotSupported()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildModeSelector(controller),
                  const SizedBox(height: 12),
                  _buildImagePreview(controller),
                  const SizedBox(height: 16),
                  _buildButtons(controller),
                  const SizedBox(height: 16),
                  _buildStatus(controller),
                  const SizedBox(height: 8),
                  Expanded(child: _buildResult(controller)),
                ],
              ),
            ),
    );
  }

  Widget _buildModeSelector(TextExtractorController controller) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('Text'),
            selected: controller.extractionMode.value == ExtractionMode.text,
            onSelected: (v) =>
                controller.setExtractionMode(ExtractionMode.text),
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text('QR/Barcode'),
            selected: controller.extractionMode.value == ExtractionMode.qr,
            onSelected: (v) => controller.setExtractionMode(ExtractionMode.qr),
          ),
        ],
      );
    });
  }

  Widget _buildNotSupported() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'This demo uses native ML Kit OCR which only works on Android and iOS.\n\n'
          'Please run the app on a mobile device or emulator.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildImagePreview(TextExtractorController controller) {
    return Obx(() {
      final File? image = controller.selectedImage.value;

      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? Image.file(
                image,
                fit: BoxFit.cover,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined,
                      size: 48, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildButtons(TextExtractorController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.scanFromCamera,
            icon: const Icon(Icons.qr_code_scanner),
            label: Obx(() => Text(
                controller.extractionMode.value == ExtractionMode.qr
                    ? 'Scan QR'
                    : 'Camera')),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.pickImageFromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Galleryy'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatus(TextExtractorController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Extracting text...'),
          ],
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              splashRadius: 18,
              onPressed: controller.clear,
            ),
          ],
        );
      }

      if (controller.extracted.value != null &&
          controller.extracted.value!.hasText) {
        return Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 18),
            const SizedBox(width: 6),
            const Text('Text extracted successfully'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              splashRadius: 18,
              onPressed: controller.clear,
            ),
          ],
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildResult(TextExtractorController controller) {
    return Obx(() {
      final extracted = controller.extracted.value;

      if (extracted == null &&
          controller.errorMessage.value.isEmpty &&
          !controller.isLoading.value) {
        return Center(
          child: Text(
            'Select or capture an image to extract text.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Text(
            extracted != null && extracted.hasText
                ? extracted.text
                : 'No text extracted.',
            style: const TextStyle(fontSize: 15),
          ),
        ),
      );
    });
  }
}
