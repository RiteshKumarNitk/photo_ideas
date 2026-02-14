
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart' show Colors, Paint, Canvas, Rect, Offset, Size, PaintingStyle, FilterQuality, BoxFit, paintImage;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../features/images/models/face_filter_model.dart'; // Corrected Path
import '../../../core/services/face_detection_service.dart'; // Adjusted if needed, likely ../services/face_detection_service.dart depending on folder structure. 
// services is in lib/core/services. utils is in lib/core/utils. So ../services is correct.
// face_filter_processor is in lib/core/utils.
// face_detection_service is in lib/core/services.
// path: ../services/face_detection_service.dart. 
// Wait, previous file had ../../../core/services/... which implies it thought it was deeper? 
// The file is at lib/core/utils/face_filter_processor.dart.
// To get to lib/core/services/face_detection_service.dart:
// ../ returns to lib/core/
// ../services/face_detection_service.dart is correct.

class FaceFilterProcessor {
  static final FaceDetectionService _faceService = FaceDetectionService();

  /// Applies the selected [filter] to the image at [imagePath].
  /// Returns the path to the newly saved image (overwriting if needed, or new file).
  static Future<String?> applyFilterToImage(
    String imagePath,
    FaceFilter filter,
  ) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      
      // Fix: decodeImageFromList is callback-based. Use instantiateImageCodec for async/await.
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      // Detect Faces in the high-res image
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceService.processImage(inputImage);

      if (faces.isEmpty || filter.cachedImage == null) {
        return imagePath; // Return original if no faces or no asset loaded
      }

      // Prepare Canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // 1. Draw Original Image
      canvas.drawImage(originalImage, Offset.zero, Paint());

      // 2. Draw Filter on Faces
      final filterImage = filter.cachedImage!;
      
      for (final face in faces) {
        _drawFilterOnFace(canvas, face, filter, filterImage, originalImage.width.toDouble(), originalImage.height.toDouble());
      }

      // 3. Save to File
      final picture = recorder.endRecording();
      final processedImage = await picture.toImage(originalImage.width, originalImage.height);
      final pngBytes = await processedImage.toByteData(format: ui.ImageByteFormat.png);
      
      if (pngBytes == null) return null;

      final newPath = imagePath.replaceAll('.jpg', '_filtered.png');
      final newFile = File(newPath);
      await newFile.writeAsBytes(pngBytes.buffer.asUint8List());

      return newPath;
    } catch (e) {
      // debugPrint("Error applying filter: $e");
      return null;
    }
  }

  static void _drawFilterOnFace(
    Canvas canvas,
    Face face,
    FaceFilter filter,
    ui.Image assetImage,
    double imageWidth,
    double imageHeight,
  ) {
    // Determine position based on anchor
    // Coordinates are already in image space (0..width, 0..height) because we used InputImage.fromFilePath
    
    double anchorX = 0;
    double anchorY = 0;
    double faceScale = 1.0;

    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];

    // Determine Scale (based on eye distance or bounding box)
    if (leftEye != null && rightEye != null) {
      // Distance between eyes
      double dx = (leftEye.position.x - rightEye.position.x).abs().toDouble();
      double dy = (leftEye.position.y - rightEye.position.y).abs().toDouble();
      faceScale = (dx * dx + dy * dy); 
      // Re-calculating as plain distance
      faceScale =  (leftEye.position.x - rightEye.position.x).abs().toDouble(); 
    } 
    
    if (leftEye != null && rightEye != null) {
       faceScale = (leftEye.position.x - rightEye.position.x).abs().toDouble();
    } else {
       faceScale = face.boundingBox.width * 0.4;
    }

    double targetWidth = faceScale * filter.scale;
    double targetHeight = targetWidth * (assetImage.height / assetImage.width);

    // Determine Anchor Logic
    if (filter.anchor == FaceLandmarkAnchor.forehead) {
      anchorX = face.boundingBox.center.dx;
      anchorY = face.boundingBox.top;
    } else if (filter.anchor == FaceLandmarkAnchor.eyes) {
      if (leftEye != null && rightEye != null) {
        anchorX = (leftEye.position.x + rightEye.position.x) / 2;
        anchorY = (leftEye.position.y + rightEye.position.y) / 2;
      } else {
        anchorX = face.boundingBox.center.dx;
        anchorY = face.boundingBox.top + (face.boundingBox.height * 0.3); // Approx eye level
      }
    } else if (filter.anchor == FaceLandmarkAnchor.nose) {
       if (noseBase != null) {
         anchorX = noseBase.position.x.toDouble();
         anchorY = noseBase.position.y.toDouble();
       } else {
         anchorX = face.boundingBox.center.dx;
         anchorY = face.boundingBox.center.dy;
       }
    } else {
       // Face Center
       anchorX = face.boundingBox.center.dx;
       anchorY = face.boundingBox.center.dy;
    }

    // Apply Offset
    anchorX += filter.offset.dx * (faceScale / 100);
    anchorY += filter.offset.dy * (faceScale / 100);

    // Rotation (Roll)
    double roll = 0;
    if (face.headEulerAngleZ != null) {
       roll = face.headEulerAngleZ! * (3.14159 / 180.0);
    }

    // Draw
    canvas.save();
    canvas.translate(anchorX, anchorY);
    canvas.rotate(roll);
    canvas.translate(-anchorX, -anchorY);

    final dstRect = Rect.fromCenter(
      center: Offset(anchorX, anchorY),
      width: targetWidth,
      height: targetHeight
    );

    paintImage(
      canvas: canvas,
      rect: dstRect,
      image: assetImage,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high 
    );
    
    canvas.restore();
  }
}
