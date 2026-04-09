import 'package:flutter/services.dart';

class HapticService {
  /// Feedback for light interactions (e.g., button taps)
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Feedback for medium interactions (e.g., toggles)
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Feedback for heavy interactions
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Feedback for success actions
  static Future<void> success() async {
    await HapticFeedback.vibrate();
  }

  /// Feedback for errors or warnings
  static Future<void> error() async {
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.vibrate();
  }
}
