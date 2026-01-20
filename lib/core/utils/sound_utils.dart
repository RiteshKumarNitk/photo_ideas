import 'package:flutter/services.dart';

class SoundUtils {
  static Future<void> playShutterSound() async {
    await SystemSound.play(SystemSoundType.click);
  }
}
