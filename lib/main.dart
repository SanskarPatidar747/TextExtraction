import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/app_theme.dart';
import 'views/text_extractor_page.dart';

void main() {
  runApp(const ExtractTextApp());
}

class ExtractTextApp extends StatelessWidget {
  const ExtractTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo Text Extractor',
      theme: AppTheme.lightTheme,
      home: const TextExtractorPage(),
    );
  }
}

