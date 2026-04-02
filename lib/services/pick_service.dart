import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class PickService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from the gallery
  static Future<String?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      return image?.path;
    } catch (e) {
      debugPrint("Error picking image: $e");
      return null;
    }
  }

  /// Pick a PDF or Image file from device storage
  static Future<String?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      debugPrint("Error picking file: $e");
      return null;
    }
  }
}
