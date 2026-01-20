import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  DateTime? _lastSpokenTime;
  
  // Throttle configuration
  final Duration _throttleDuration = const Duration(seconds: 3);

  TtsService() {
    _flutterTts = FlutterTts();
    _initialize();
  }

  void _initialize() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Slower speech is clearer for instructions
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint("TTS Error: $msg");
      });
    } catch (e) {
      debugPrint("TTS Init Error: $e");
    }
  }

  Future<void> speak(String text, {bool force = false}) async {
    if (text.isEmpty) return;
    
    // Throttling logic
    if (!force) {
      if (_isSpeaking) return;
      if (_lastSpokenTime != null && DateTime.now().difference(_lastSpokenTime!) < _throttleDuration) {
        return;
      }
    }

    try {
      _lastSpokenTime = DateTime.now();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error speaking: $e");
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
