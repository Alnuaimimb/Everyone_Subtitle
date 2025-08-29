import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileImprovementService {
  static final GetStorage _storage = GetStorage();
  static const String _responseChoicesKey = 'responseChoices';
  static const String _profileImprovementsKey = 'profileImprovements';

  // Save user's response choice for profile improvement
  static Future<void> saveResponseChoice({
    required String transcript,
    required String selectedResponse,
  }) async {
    try {
      final choice = {
        'timestamp': DateTime.now().toIso8601String(),
        'transcript': transcript,
        'selectedResponse': selectedResponse,
      };

      // Save locally
      final choices = _storage.read<List>(_responseChoicesKey) ?? [];
      choices.add(choice);
      await _storage.write(_responseChoicesKey, choices);

      // Save to Firestore if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('responseChoices')
            .add(choice);
      }

      print('[Profile] Saved response choice: $selectedResponse');
    } catch (e) {
      print('[Profile] Failed to save response choice: $e');
    }
  }

  // Get user's response choice history
  static List<Map<String, dynamic>> getResponseChoices() {
    try {
      final choices = _storage.read<List>(_responseChoicesKey) ?? [];
      return choices.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[Profile] Failed to get response choices: $e');
      return [];
    }
  }

  // Analyze user preferences and suggest profile improvements
  static Map<String, dynamic> analyzeUserPreferences() {
    try {
      final choices = getResponseChoices();
      if (choices.isEmpty) {
        return {'needsImprovement': false, 'suggestions': []};
      }

      // Analyze response patterns for single responses
      final totalChoices = choices.length;
      final suggestions = <String>[];

      // Simple analysis based on response content
      int formalResponses = 0;
      int casualResponses = 0;
      int empatheticResponses = 0;

      for (final choice in choices) {
        final response =
            (choice['selectedResponse'] as String? ?? '').toLowerCase();

        if (response.contains('i am') ||
            response.contains('do not') ||
            response.contains('would you')) {
          formalResponses++;
        }
        if (response.contains("i'm") ||
            response.contains("don't") ||
            response.contains('hey') ||
            response.contains('yeah')) {
          casualResponses++;
        }
        if (response.contains('understand') ||
            response.contains('feel') ||
            response.contains('hope')) {
          empatheticResponses++;
        }
      }

      if (formalResponses > totalChoices * 0.6) {
        suggestions.add(
            'You tend to use formal language. Your profile reflects this preference.');
      }
      if (casualResponses > totalChoices * 0.6) {
        suggestions.add(
            'You prefer casual communication. Your profile matches this style.');
      }
      if (empatheticResponses > totalChoices * 0.5) {
        suggestions.add(
            'You often choose empathetic responses. This shows in your communication style.');
      }

      return {
        'needsImprovement': false, // Profile learning is ongoing
        'suggestions': suggestions,
        'stats': {
          'totalChoices': totalChoices,
          'formalResponses': formalResponses,
          'casualResponses': casualResponses,
          'empatheticResponses': empatheticResponses,
        }
      };
    } catch (e) {
      print('[Profile] Failed to analyze preferences: $e');
      return {'needsImprovement': false, 'suggestions': []};
    }
  }

  // Clear response choice history
  static Future<void> clearResponseChoices() async {
    try {
      await _storage.remove(_responseChoicesKey);
      print('[Profile] Cleared response choices');
    } catch (e) {
      print('[Profile] Failed to clear response choices: $e');
    }
  }
}
