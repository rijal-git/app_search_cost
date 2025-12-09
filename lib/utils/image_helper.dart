import 'dart:convert';
import 'package:flutter/material.dart';

class ImageHelper {
  /// Decodes a Base64 string to an ImageProvider.
  static ImageProvider imageFromBase64String(String base64String) {
    return MemoryImage(base64Decode(base64String));
  }
}
