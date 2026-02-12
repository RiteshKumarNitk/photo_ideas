import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

class FaceDetectionService {
  late final FaceDetector _faceDetector;
  bool _isInitialized = false;

  FaceDetectionService() {
    _initialize();
  }

  void _initialize() {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true, 
      performanceMode: FaceDetectorMode.accurate, 
    );
    _faceDetector = FaceDetector(options: options);
    _isInitialized = true;
  }

  Future<List<Face>> processImage(InputImage inputImage) async {
    if (!_isInitialized) return [];
    try {
      return await _faceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint("Error processing face: $e");
      return [];
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
