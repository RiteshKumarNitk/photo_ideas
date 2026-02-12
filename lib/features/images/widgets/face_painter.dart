import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import for CameraLensDirection
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/face_filter_model.dart';

enum FaceFilterType {
  none,
  sunglasses,
  catEars,
  clownNose,
  debug,
}


// ... other imports

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final FaceFilter? filter; // Changed from enum to Model

  FacePainter({
    required this.faces,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
    this.filter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (filter == null || filter!.type == FaceFilterCapability.none) return;

    for (final face in faces) {
      if (filter!.type == FaceFilterCapability.asset && filter!.cachedImage != null) {
        _paintAsset(canvas, face, size);
      } else {
        // Fallback for procedural debug or specific types handled by code
        // For now, simple dot for debug if no asset logic matches
      }
    }
  }

  void _paintAsset(Canvas canvas, Face face, Size size) {
    if (filter!.cachedImage == null) return;
    final image = filter!.cachedImage!;
    
    // Determine position based on anchor
    Offset? position;
    double width = 0;
    
    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];
    // Calculate face width/scale
    // Use eye distance as a metric
    double faceScale = 1.0;
    
    if (leftEye != null && rightEye != null) {
       final lx = _translateX(leftEye.position.x.toDouble(), rotation, size, imageSize, cameraLensDirection);
       final rx = _translateX(rightEye.position.x.toDouble(), rotation, size, imageSize, cameraLensDirection);
       faceScale = (lx - rx).abs(); // Distance between eyes in pixels
    } else {
      // Fallback to bounding box width
       final rect = _scaleRect(rect: face.boundingBox, imageSize: imageSize, widgetSize: size, rotation: rotation, cameraLensDirection: cameraLensDirection);
       faceScale = rect.width * 0.4;
    }

    double targetWidth = faceScale * filter!.scale;
    double targetHeight = targetWidth * (image.height / image.width);

    // Calculate Anchor Point X,Y
    double anchorX = 0;
    double anchorY = 0;

    if (filter!.anchor == FaceLandmarkAnchor.forehead) {
       // Approximate forehead: Above eyes. 
       // Bounding box top is usually forehead top.
       final rect = _scaleRect(rect: face.boundingBox, imageSize: imageSize, widgetSize: size, rotation: rotation, cameraLensDirection: cameraLensDirection);
       anchorX = rect.center.dx;
       anchorY = rect.top; // Top of box
    } else if (filter!.anchor == FaceLandmarkAnchor.eyes) {
       if (leftEye != null && rightEye != null) {
          final ly = _translateY(leftEye.position.y.toDouble(), rotation, size, imageSize, cameraLensDirection);
          final ry = _translateY(rightEye.position.y.toDouble(), rotation, size, imageSize, cameraLensDirection);
          final lx = _translateX(leftEye.position.x.toDouble(), rotation, size, imageSize, cameraLensDirection);
          final rx = _translateX(rightEye.position.x.toDouble(), rotation, size, imageSize, cameraLensDirection);
          anchorX = (lx + rx) / 2;
          anchorY = (ly + ry) / 2;
       }
    } else if (filter!.anchor == FaceLandmarkAnchor.nose) {
       if (noseBase != null) {
          anchorX = _translateX(noseBase.position.x.toDouble(), rotation, size, imageSize, cameraLensDirection);
          anchorY = _translateY(noseBase.position.y.toDouble(), rotation, size, imageSize, cameraLensDirection);
       }
    }
    
    // Apply Offset (scaled by face size)
    anchorX += filter!.offset.dx * (faceScale / 100); 
    anchorY += filter!.offset.dy * (faceScale / 100);

    // Draw Image Centered at Anchor
    final dstRect = Rect.fromCenter(center: Offset(anchorX, anchorY), width: targetWidth, height: targetHeight);
    
    // Calculate Rotation (Roll)
    // Head Euler Z
    // Default ML Kit gives headEulerAngleZ in degrees.
    // Positive Z is CCW? Check.
    double roll = 0;
    if (face.headEulerAngleZ != null) {
       roll = face.headEulerAngleZ! * (pi / 180.0);
       // Adjust for camera mirror if needed? front camera mirrors.
       if (cameraLensDirection == CameraLensDirection.front) {
          roll = -roll; 
       }
    }

    canvas.save();
    canvas.translate(anchorX, anchorY);
    canvas.rotate(roll); 
    canvas.translate(-anchorX, -anchorY);
    
    paintImage(
      canvas: canvas,
      rect: dstRect,
      image: image,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) {
    return oldDelegate.faces != faces || oldDelegate.filter != filter;
  }
}

double _translateX(
  double x,
  InputImageRotation rotation,
  Size size,
  Size absoluteImageSize,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
    case InputImageRotation.rotation270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double _translateY(
  double y,
  InputImageRotation rotation,
  Size size,
  Size absoluteImageSize,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          size.height /
          (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}

Rect _scaleRect({
  required Rect rect,
  required Size imageSize,
  required Size widgetSize,
  required InputImageRotation rotation,
  required CameraLensDirection cameraLensDirection,
}) {
  final double left = _translateX(
    rect.left,
    rotation,
    widgetSize,
    imageSize,
    cameraLensDirection,
  );
  final double top = _translateY(
    rect.top,
    rotation,
    widgetSize,
    imageSize,
    cameraLensDirection,
  );
  final double right = _translateX(
    rect.right,
    rotation,
    widgetSize,
    imageSize,
    cameraLensDirection,
  );
  final double bottom = _translateY(
    rect.bottom,
    rotation,
    widgetSize,
    imageSize,
    cameraLensDirection,
  );

  return Rect.fromLTRB(left, top, right, bottom);
}

