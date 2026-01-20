import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';

class ImageDownloader {
  static Future<File?> downloadToTemp(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        // Unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempFile = File('${tempDir.path}/temp_ref_$timestamp.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);
        return tempFile;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading to temp: $e');
      return null;
    }
  }

  static Future<bool> downloadImage(String url) async {
    try {
      final File? tempFile = await downloadToTemp(url);
      if (tempFile != null) {
        // Save using Gal
        await Gal.putImage(tempFile.path);
        
        // Delete temp file
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return false;
    }
  }
}
