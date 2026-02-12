class ExtractedTextModel {
  final String text;

  const ExtractedTextModel({required this.text});

  bool get hasText => text.trim().isNotEmpty;
}

