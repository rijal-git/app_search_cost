import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // ⚠️ TODO: Ganti dengan cloud name Anda
  // Cara dapet: https://cloudinary.com/console/settings/api-keys
  static const String CLOUD_NAME = "YOUR_CLOUD_NAME";
  static const String UPLOAD_PRESET = "YOUR_UPLOAD_PRESET";

  final String cloudName;
  final String uploadPreset;

  CloudinaryService({required this.cloudName, required this.uploadPreset});

  /// 📤 Upload foto ke Cloudinary
  /// Returns URL dari foto yang di-upload
  Future<String?> uploadImage(
    File imageFile, {
    String folder = "app_search_cost",
    String? fileName,
  }) async {
    try {
      debugPrint("📤 Uploading to Cloudinary...");
      debugPrint("   File: ${imageFile.path}");
      debugPrint("   Size: ${imageFile.lengthSync() / 1024} KB");

      // 1. Prepare upload URL
      final uploadUrl = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      // 2. Create multipart request
      final request = http.MultipartRequest("POST", uploadUrl);

      // 3. Add file
      request.files.add(
        await http.MultipartFile.fromPath("file", imageFile.path),
      );

      // 4. Add parameters
      request.fields["upload_preset"] = uploadPreset;
      request.fields["folder"] = folder;
      if (fileName != null) {
        request.fields["public_id"] = fileName;
      }

      // 5. Send request
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      debugPrint("📡 Response status: ${response.statusCode}");

      // 6. Parse response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final imageUrl = jsonResponse['secure_url'];

        debugPrint("✅ Upload successful!");
        debugPrint("   URL: $imageUrl");

        return imageUrl;
      } else {
        debugPrint("❌ Upload failed: ${response.statusCode}");
        debugPrint("   Body: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error uploading image: $e");
      return null;
    }
  }

  /// 📤 Upload multiple images
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    String folder = "app_search_cost",
  }) async {
    final uploadedUrls = <String>[];

    for (int i = 0; i < imageFiles.length; i++) {
      debugPrint("Uploading image ${i + 1}/${imageFiles.length}...");

      final url = await uploadImage(imageFiles[i], folder: folder);

      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    debugPrint("✅ All uploads complete. Total: ${uploadedUrls.length}");
    return uploadedUrls;
  }

  /// 🔗 Generate optimized URL dengan transformasi
  /// Untuk resize, compress, dll
  static String getOptimizedUrl(
    String imageUrl, {
    int width = 400,
    int height = 400,
    String quality = "auto",
    String crop = "fill",
  }) {
    // URL format: https://res.cloudinary.com/CLOUD_NAME/image/fetch/
    // w_400,h_400,c_fill,q_auto/OTHER_IMAGE_URL

    // Jika sudah Cloudinary URL, extract base
    if (imageUrl.contains("res.cloudinary.com")) {
      return imageUrl; // Sudah optimized
    }

    // Untuk URL eksternal
    final encodedUrl = Uri.encodeComponent(imageUrl);
    return "https://res.cloudinary.com/YOUR_CLOUD_NAME/image/fetch/"
        "w_$width,h_$height,c_$crop,q_$quality/"
        "$encodedUrl";
  }

  /// 🗑️ Delete image dari Cloudinary
  /// (Optional - jika ingin cleanup)
  Future<bool> deleteImage(String publicId) async {
    try {
      debugPrint("🗑️ Deleting: $publicId");

      final deleteUrl = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/destroy",
      );

      final request = http.MultipartRequest("POST", deleteUrl);
      request.fields["public_id"] = publicId;
      request.fields["upload_preset"] = uploadPreset;

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        debugPrint("✅ Deleted successfully");
        return true;
      } else {
        debugPrint("❌ Delete failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error deleting image: $e");
      return false;
    }
  }
}
