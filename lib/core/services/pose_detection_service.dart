import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

class PoseDetectionService {
  late final PoseDetector _poseDetector;
  bool _isInitialized = false;

  PoseDetectionService() {
    _initialize();
  }

  void _initialize() {
    // Use Base model for better performance on real-time video
    final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
    _poseDetector = PoseDetector(options: options);
    _isInitialized = true;
  }
  
  String getPoseFeedback(Pose reference, Pose user) {
     if (reference.landmarks.isEmpty || user.landmarks.isEmpty) return "Pose not detected";
     
     // Check Arm Angles
     final leftArmRef = _getAngle(reference, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
     final leftArmUser = _getAngle(user, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
     
     if (leftArmRef != null && leftArmUser != null) {
       double diff = (leftArmRef - leftArmUser).abs();
       if (diff > 25) {
         return leftArmUser < leftArmRef ? "Straighten Left Arm" : "Bend Left Arm";
       }
     }

     final rightArmRef = _getAngle(reference, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
     final rightArmUser = _getAngle(user, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
     
     if (rightArmRef != null && rightArmUser != null) {
       double diff = (rightArmRef - rightArmUser).abs();
       if (diff > 25) {
         return rightArmUser < rightArmRef ? "Straighten Right Arm" : "Bend Right Arm";
       }
     }
     
     // Check Shoulder-Joints (Raise/Lower Arms) - using Y coordinate relative to shoulder?
     // Or just angles? Stick to angles for simplicity and robustness.
     // Angle: Hip-Shoulder-Elbow
     
     final leftShoulderRef = _getAngle(reference, PoseLandmarkType.leftHip, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
     final leftShoulderUser = _getAngle(user, PoseLandmarkType.leftHip, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
     
     if (leftShoulderRef != null && leftShoulderUser != null) {
        double diff = (leftShoulderRef - leftShoulderUser).abs();
        if (diff > 25) {
           // Larger angle usually means arm is higher (away from body)
           return leftShoulderUser < leftShoulderRef ? "Raise Left Arm" : "Lower Left Arm";
        }
     }
     
     final rightShoulderRef = _getAngle(reference, PoseLandmarkType.rightHip, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
     final rightShoulderUser = _getAngle(user, PoseLandmarkType.rightHip, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
     
     if (rightShoulderRef != null && rightShoulderUser != null) {
        double diff = (rightShoulderRef - rightShoulderUser).abs();
        if (diff > 25) {
           return rightShoulderUser < rightShoulderRef ? "Raise Right Arm" : "Lower Right Arm";
        }
     }
     
     return "Perfect Match!";
  }

  Future<List<Pose>> processImage(InputImage inputImage) async {
    if (!_isInitialized) return [];
    try {
      return await _poseDetector.processImage(inputImage);
    } catch (e) {
      debugPrint("Error processing pose: $e");
      return [];
    }
  }

  /// Calculates a similarity score (0-100) between two poses based on joint angles.
  double calculateSimilarity(Pose reference, Pose user) {
    if (reference.landmarks.isEmpty || user.landmarks.isEmpty) return 0.0;

    // Key joints to compare
    final anglesToCheck = [
      // Left Arm
      (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),
      (PoseLandmarkType.leftHip, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow),
      
      // Right Arm
      (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),
      (PoseLandmarkType.rightHip, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow),
      
      // Legs (optional, might be hidden in selfies)
      // (PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),
      // (PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
    ];

    double totalDiff = 0.0;
    int count = 0;

    for (var triplet in anglesToCheck) {
      final double? angleRef = _getAngle(reference, triplet.$1, triplet.$2, triplet.$3);
      final double? angleUser = _getAngle(user, triplet.$1, triplet.$2, triplet.$3);

      if (angleRef != null && angleUser != null) {
        // Calculate absolute difference in degrees
        double diff = (angleRef - angleUser).abs();
        // Normalize: if diff > 180, take the shorter way? 
        // Angles are usually 0-180 in this context. 
        if (diff > 180) diff = 360 - diff;
        
        totalDiff += diff;
        count++;
      }
    }

    if (count == 0) return 0.0;

    // Average difference per joint
    double avgDiff = totalDiff / count;

    // Convert diff to score. 
    // If avgDiff is 0, score is 100.
    // If avgDiff is 45 degrees, score is maybe 50?
    // Let's say tolerance is loose. 
    double score = (1.0 - (avgDiff / 90.0)).clamp(0.0, 1.0) * 100;
    
    return score;
  }

  double? _getAngle(Pose pose, PoseLandmarkType p1, PoseLandmarkType p2, PoseLandmarkType p3) {
    final l1 = pose.landmarks[p1];
    final l2 = pose.landmarks[p2];
    final l3 = pose.landmarks[p3];

    if (l1 == null || l2 == null || l3 == null) return null;
    
    // Check likelihood/visibility
    if (l1.likelihood < 0.5 || l2.likelihood < 0.5 || l3.likelihood < 0.5) return null;

    // Calculate angle at p2
    return _calculateAngle(
      l1.x, l1.y,
      l2.x, l2.y,
      l3.x, l3.y,
    );
  }

  double _calculateAngle(double x1, double y1, double x2, double y2, double x3, double y3) {
    // Vector 1: P2 -> P1
    double v1x = x1 - x2;
    double v1y = y1 - y2;
    
    // Vector 2: P2 -> P3
    double v2x = x3 - x2;
    double v2y = y3 - y2;
    
    // Dot product
    double dot = v1x * v2x + v1y * v2y;
    
    // Magnitudes
    double mag1 = math.sqrt(v1x * v1x + v1y * v1y);
    double mag2 = math.sqrt(v2x * v2x + v2y * v2y);
    
    if (mag1 * mag2 == 0) return 0.0;
    
    // Cosine of angle
    double cosAngle = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return math.acos(cosAngle) * 180 / math.pi;
  }

  void dispose() {
    _poseDetector.close();
  }
}
