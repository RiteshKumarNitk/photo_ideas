import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

class MLKitUtils {
  static InputImage? convertCameraImage(CameraImage image, CameraDescription camera) {
    final allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final InputImageRotation imageRotation = _rotationIntToImageRotation(camera.sensorOrientation);
    final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    // Updated API for google_mlkit_commons > 0.6.0
    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow, // API usually requires this now
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  static InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }
}
