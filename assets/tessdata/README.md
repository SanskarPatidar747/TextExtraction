# Tesseract language data (required for Web & Desktop OCR)

Download **eng.traineddata** and place it in this folder.

- **Option 1 (smaller, ~2MB):**  
  https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata  
- **Option 2 (full):**  
  https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata  

Then ensure `pubspec.yaml` includes:
```yaml
flutter:
  assets:
    - assets/tessdata_config.json
    - assets/tessdata/
```
