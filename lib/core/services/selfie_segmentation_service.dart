import 'dart:ui';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class SelfieSegmentationService {
  final SelfieSegmenter _segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
    enableRawSizeMask: true,
  );

  bool _isBusy = false;

  Future<SegmentationMask?> processImage(InputImage inputImage) async {
    if (_isBusy) return null;
    _isBusy = true;

    try {
      final mask = await _segmenter.processImage(inputImage);
      _isBusy = false;
      return mask;
    } catch (e) {
      debugPrint("Segmentation Error: $e");
      _isBusy = false;
      return null;
    }
  }

  void dispose() {
    _segmenter.close();
  }
}
