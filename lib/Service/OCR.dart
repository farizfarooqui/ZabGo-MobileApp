import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class OCRValidator {
  static const String _apiKey = 'K85595973088957';

  static Future<String?> extractText(File imageFile) async {
    try {
      print("🔍 Compressing image before OCR...");

      // Read image bytes
      final originalBytes = await imageFile.readAsBytes();
      print(
          "📏 Original size: ${(originalBytes.lengthInBytes / 1024).toStringAsFixed(2)} KB");

      // Decode and resize (works on all platforms)
      img.Image? decoded = img.decodeImage(originalBytes);
      if (decoded == null) throw Exception("Failed to decode image");

      // Resize to ~1024px max dimension to ensure <1MB
      final resized = img.copyResize(decoded, width: 1024);
      final compressedBytes = img.encodeJpg(resized, quality: 70);

      print(
          "📉 Compressed size: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB");

      final base64Image = base64Encode(compressedBytes);

      // Send to OCR.Space
      print("📤 Sending to OCR...");
      final response = await http.post(
        Uri.parse('https://api.ocr.space/parse/image'),
        headers: {'apikey': _apiKey},
        body: {
          'base64Image': 'data:image/jpeg;base64,$base64Image',
          'language': 'eng',
        },
      );

      print("📡 OCR API Response Code: ${response.statusCode}");
      final data = jsonDecode(response.body);
      print("🧾 Full OCR API Response: ${jsonEncode(data)}\n");

      if (data['IsErroredOnProcessing'] == true ||
          data['ParsedResults'] == null ||
          data['ParsedResults'].isEmpty) {
        print("⚠️ OCR: No parsed text found in response.");
        return null;
      }

      final extractedText =
          data['ParsedResults'][0]['ParsedText']?.toString() ?? '';
      print("✅ Extracted Text:\n$extractedText");

      return extractedText;
    } catch (e) {
      print('🚨 OCR Exception: $e');
      return null;
    }
  }

  static bool isValidUniversityID(String text) {
    final normalized =
        text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9 ]'), ' ');

    // ✅ Check for university name (OCR may miss spaces or letters)
    final hasUniversityName = normalized.contains("SHAHEED ZULFIKAR") &&
        (normalized.contains("BHUTTO") || normalized.contains("ZULFIKARALI")) &&
        (normalized.contains("INSTITUTE") || normalized.contains("UNIVERSITY"));

    // ✅ Must mention student ID
    final hasStudentCardText = normalized.contains("STUDENT") &&
        (normalized.contains("IDENTITY") || normalized.contains("CARD"));

    // ✅ Must contain registration info
    final hasRegNo =
        normalized.contains("REG") || normalized.contains("REGISTRATION");

    // ✅ Must have a number that looks like a student reg number (6–8 digits)
    final regNumberPattern = RegExp(r'\b\d{6,8}\b');
    final hasNumericID = regNumberPattern.hasMatch(normalized);

    // ✅ Must contain a valid campus name
    final hasCampus = normalized.contains("HYDERABAD") ||
        normalized.contains("KARACHI") ||
        normalized.contains("ISLAMABAD");

    // Combine all
    final isValid = hasUniversityName &&
        hasStudentCardText &&
        hasRegNo &&
        hasNumericID &&
        hasCampus;

    print('🔎 Validation Summary:');
    print('   🏫 University Name: $hasUniversityName');
    print('   🪪 Student Card Text: $hasStudentCardText');
    print('   🔢 Reg No Found: $hasRegNo');
    print('   🔍 Numeric ID: $hasNumericID');
    print('   📍 Campus: $hasCampus');
    print('➡️  Valid University ID: $isValid');

    return isValid;
  }
}
