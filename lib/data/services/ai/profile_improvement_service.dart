import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';
import 'package:everyone_subtitle/data/services/ai/openai_service.dart';

class ProfileImprovementService {
  static final GetStorage _storage = GetStorage();

  // Save response choice for profile improvement
  static Future<void> saveResponseChoice({
    required String transcript,
    required String selectedResponse,
    required String selectedOption,
    required UserProfile currentProfile,
  }) async {
    try {
      final history = _storage.read('responseHistory') ?? [];

      final choice = {
        'timestamp': DateTime.now().toIso8601String(),
        'transcript': transcript,
        'selectedResponse': selectedResponse,
        'selectedOption': selectedOption,
        'userProfile': currentProfile.toJson(),
      };

      history.add(choice);
      _storage.write('responseHistory', history);

      // Keep only last 50 responses to avoid memory issues
      if (history.length > 50) {
        history.removeRange(0, history.length - 50);
        _storage.write('responseHistory', history);
      }

      print('Response choice saved for profile improvement');
    } catch (e) {
      print('Error saving response choice: $e');
    }
  }

  // Improve profile based on response history
  static Future<UserProfile?> improveProfile(UserProfile currentProfile) async {
    try {
      final history = _storage.read('responseHistory') ?? [];

      if (history.length < 5) {
        // Need at least 5 responses to improve profile
        return null;
      }

      // Analyze recent responses (last 10)
      final recentHistory = history.take(10).toList();

      // Create improvement prompt
      final prompt = _buildImprovementPrompt(currentProfile, recentHistory);

      // TODO: Implement profile improvement with OpenAI
      // For now, return null to indicate no improvement
      print('Profile improvement not yet implemented');
      return null;
    } catch (e) {
      print('Error improving profile: $e');
      return null;
    }
  }

  static String _buildImprovementPrompt(
      UserProfile profile, List<dynamic> history) {
    final historyText = history
        .map((h) =>
            'Transcript: "${h['transcript']}" -> Response: "${h['selectedResponse']}" (Option: ${h['selectedOption']})')
        .join('\n');

    return '''
Based on the user's response history, improve their communication profile:

Current Profile:
- Summary: ${profile.summary}
- Traits: ${profile.traits.join(', ')}
- Speaking Style: ${profile.speakingStyle}
- Tone Preferences: ${profile.tonePreferences.join(', ')}

Response History:
$historyText

Please analyze the patterns in their responses and update the profile to better reflect their actual communication preferences. Return the improved profile in JSON format.
''';
  }

  // Get response statistics
  static Map<String, dynamic> getResponseStats() {
    try {
      final history = _storage.read('responseHistory') ?? [];

      if (history.isEmpty) {
        return {
          'totalResponses': 0,
          'mostUsedOption': 'None',
          'averageResponseLength': 0,
        };
      }

      // Count option usage
      final optionCounts = <String, int>{};
      double totalLength = 0;

      for (final response in history) {
        final option = response['selectedOption'] ?? 'Unknown';
        optionCounts[option] = (optionCounts[option] ?? 0) + 1;

        final responseText = response['selectedResponse'] ?? '';
        totalLength += responseText.length;
      }

      final mostUsedOption =
          optionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return {
        'totalResponses': history.length,
        'mostUsedOption': mostUsedOption,
        'averageResponseLength': totalLength / history.length,
        'optionBreakdown': optionCounts,
      };
    } catch (e) {
      print('Error getting response stats: $e');
      return {
        'totalResponses': 0,
        'mostUsedOption': 'None',
        'averageResponseLength': 0,
      };
    }
  }
}
