import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Normal speed
      await _flutterTts.setVolume(1.0); // Full volume
      await _flutterTts.setPitch(1.0); // Normal pitch
      _isInitialized = true;
      print('[TTS] Service initialized successfully');
    } catch (e) {
      print('[TTS] Failed to initialize: $e');
    }
  }

  static Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('[TTS] Speaking: "$text"');
      await _flutterTts.speak(text);
    } catch (e) {
      print('[TTS] Failed to speak: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
      print('[TTS] Stopped speaking');
    } catch (e) {
      print('[TTS] Failed to stop: $e');
    }
  }

  static Future<bool> isSpeaking() async {
    try {
      // FlutterTts doesn't have isSpeaking method, we'll track it manually
      return false; // For now, assume not speaking
    } catch (e) {
      print('[TTS] Failed to check speaking status: $e');
      return false;
    }
  }

  static void dispose() {
    _flutterTts.stop();
  }
}
