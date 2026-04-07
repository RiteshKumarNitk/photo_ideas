import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum HandGesture {
  raisedHand,
  peace,
  thumbsUp,
  thumbsDown,
  openPalm,
  fist,
  pointing,
}

class GestureMLService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
    ),
  );

  Future<List<HandGesture>> detectGestures(InputImage inputImage) async {
    final gestures = <HandGesture>[];

    try {
      final faces = await _faceDetector.processImage(inputImage);

      for (final face in faces) {
        // Smile detection
        if (face.smilingProbability != null && face.smilingProbability! > 0.7) {
          // Smiling - could be used for smile capture
        }

        // Eye tracking for gaze direction
        if (face.leftEyeOpenProbability != null &&
            face.rightEyeOpenProbability != null) {
          // Eyes open state
        }
      }

      // Additional gesture detection based on pose could be added here
      // For now, we'll use face-based detection
    } catch (e) {
      // Gesture detection error
    }

    return gestures;
  }

  void dispose() {
    _faceDetector.close();
  }
}

class SimpleHandGestureDetector {
  static List<HandGesture> detectFromPose(Pose pose) {
    final gestures = <HandGesture>[];

    final landmarks = pose.landmarks;

    // Get key landmarks
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftEar = landmarks[PoseLandmarkType.leftEar];
    final rightEar = landmarks[PoseLandmarkType.rightEar];
    final nose = landmarks[PoseLandmarkType.nose];

    if (leftWrist == null ||
        rightWrist == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return gestures;
    }

    // Check for raised hand (wrist above shoulder)
    if (leftWrist.y < leftShoulder.y - 50) {
      gestures.add(HandGesture.raisedHand);
    }
    if (rightWrist.y < rightShoulder.y - 50) {
      gestures.add(HandGesture.raisedHand);
    }

    // Check for thumbs up (wrist above nose/ears)
    if (leftEar != null && leftWrist.y < leftEar.y - 30) {
      gestures.add(HandGesture.thumbsUp);
    }
    if (rightEar != null && rightWrist.y < rightEar.y - 30) {
      gestures.add(HandGesture.thumbsUp);
    }

    // Check for peace sign (two hands raised)
    if (leftWrist.y < leftShoulder.y - 50 &&
        rightWrist.y < rightShoulder.y - 50) {
      gestures.add(HandGesture.peace);
    }

    // Check for open palm (both wrists above shoulders)
    if (leftWrist.y < leftShoulder.y - 30 &&
        rightWrist.y < rightShoulder.y - 30) {
      gestures.add(HandGesture.openPalm);
    }

    return gestures;
  }

  static bool detectPeaceSign(Pose pose) {
    final landmarks = pose.landmarks;

    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftWrist == null ||
        rightWrist == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return false;
    }

    // Both wrists raised for peace sign
    return leftWrist.y < leftShoulder.y - 50 &&
        rightWrist.y < rightShoulder.y - 50;
  }

  static bool detectRaisedHand(Pose pose) {
    final landmarks = pose.landmarks;

    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftWrist == null ||
        rightWrist == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return false;
    }

    // At least one wrist above shoulder
    return leftWrist.y < leftShoulder.y - 50 ||
        rightWrist.y < rightShoulder.y - 50;
  }
}
