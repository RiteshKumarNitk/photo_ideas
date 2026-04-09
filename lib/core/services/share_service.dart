import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/photo_model.dart';
import 'api_service.dart';

class ShareService {
  static final GlobalKey shareWidgetKey = GlobalKey();

  static Future<File?> _captureWidgetToImage(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/snapideas_share_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  static Future<void> shareWidget(GlobalKey key, String text) async {
    final file = await _captureWidgetToImage(key);
    if (file != null) {
      await Share.shareXFiles([XFile(file.path)], text: text);
    }
  }
}
