import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';

class ImageDownloader {
  static Future<bool> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Create a temporary file
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/temp_image.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);

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
