import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FilterAssetService {
  static final Map<String, ui.Image> _imageCache = {};

  static Future<ui.Image?> loadFilterAsset(String url) async {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }

    try {
      final Completer<ui.Image> completer = Completer();
      
      // Fetch the image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('Failed to load asset');
      
      final Uint8List bytes = response.bodyBytes;
      
      // Decode
      ui.decodeImageFromList(bytes, (ui.Image img) {
        if (!completer.isCompleted) {
          completer.complete(img);
        }
      });

      final image = await completer.future;
      _imageCache[url] = image;
      return image;
    } catch (e) {
      debugPrint("Error loading filter asset: $e");
      return null;
    }
  }
}
