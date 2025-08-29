import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';

class OpenAIService {
  // Single stable path for MVP
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini'; // supported chat model

  // Set via: flutter run --dart-define=ENABLE_OPENAI=true
  static const bool _useRemote =
      bool.fromEnvironment('ENABLE_OPENAI', defaultValue: true);

  // Prefer --dart-define=OPENAI_API_KEY=sk-... ; else fallback (MVP only)
  static String get _apiKey {
    const k = String.fromEnvironment('OPENAI_API_KEY');
    if (k.isNotEmpty) return k;

    // ⚠️ For hackathon only. Replace/remove for production.
    const hardcoded =
        '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';
    return hardcoded;
  }

  // ===== Step 1: Build profile from quiz answers =====
  static Future<UserProfile> generateUserProfile(
      List<Map<String, String>> answers) async {
    print(
        '[OpenAI] useRemote=$_useRemote model=$_model keyLen=${_apiKey.length}');
    try {
      if (!_useRemote) return _fallbackFromAnswers(answers);

      final prompt = _buildProfilePrompt(answers);

      final resp = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a personality analysis expert. Return ONLY JSON.'
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content =
            (data['choices']?[0]?['message']?['content'] ?? '') as String;
        return _parseProfileFromResponse(content);
      } else {
        print('[OpenAI] Profile HTTP ${resp.statusCode}: ${resp.body}');
        return _fallbackFromAnswers(answers);
      }
    } catch (e) {
      print('[OpenAI] Profile exception: $e');
      return _fallbackFromAnswers(answers);
    }
  }

  static String _buildProfilePrompt(List<Map<String, String>> answers) {
    final answersText = answers
        .map((a) => 'Q: ${a['question']}\nA: ${a['answer']}')
        .join('\n\n');

    return '''
Based on the answers below, return ONLY a JSON object (no prose):

$answersText

{
  "summary": "2–3 sentence summary",
  "traits": ["trait1","trait2","trait3"],
  "tone_preferences": ["pref1","pref2"],
  "speaking_style": "short description"
}
''';
  }

  static UserProfile _parseProfileFromResponse(String response) {
    try {
      final s = response.indexOf('{');
      final e = response.lastIndexOf('}') + 1;
      final jsonString = response.substring(s, e);
      final data = jsonDecode(jsonString);

      return UserProfile(
        summary: data['summary'] ?? 'No summary available',
        traits: List<String>.from(data['traits'] ?? const []),
        tonePreferences:
            List<String>.from(data['tone_preferences'] ?? const []),
        speakingStyle: data['speaking_style'] ?? 'Standard',
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return UserProfile(
        summary: 'Unable to generate profile.',
        traits: const ['Adaptable', 'Communicative'],
        tonePreferences: const ['Professional', 'Friendly'],
        speakingStyle: 'Balanced',
        createdAt: DateTime.now(),
      );
    }
  }

  // ===== Step 3: Single reply for FinalResponse flow =====
  static Future<String> generateSingleResponse({
    required String transcript,
    UserProfile? userProfile,
  }) async {
    print(
        '[OpenAI] useRemote=$_useRemote model=$_model keyLen=${_apiKey.length}');
    try {
      if (!_useRemote) return _fallbackSingleResponse(transcript, userProfile);

      final profileInfo = userProfile != null
          ? '''
User Profile:
- Summary: ${userProfile.summary}
- Traits: ${userProfile.traits.join(', ')}
- Style: ${userProfile.speakingStyle}
- Tones: ${userProfile.tonePreferences.join(', ')}
'''
          : 'No profile available.';

      final prompt = '''
Return ONLY a 1–2 sentence reply that matches the user style.

Transcript: "$transcript"

$profileInfo
''';

      final resp = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You generate concise, natural replies aligned with the user style. Return text only.'
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.8,
              'max_tokens': 120,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content =
            (data['choices']?[0]?['message']?['content'] ?? '') as String;
        if (content.trim().isNotEmpty) return content.trim();
        print('[OpenAI] Empty content in success response.');
        return _fallbackSingleResponse(transcript, userProfile);
      } else {
        print('[OpenAI] SingleResp HTTP ${resp.statusCode}: ${resp.body}');
        return _fallbackSingleResponse(transcript, userProfile);
      }
    } catch (e) {
      print('[OpenAI] SingleResp exception: $e');
      return _fallbackSingleResponse(transcript, userProfile);
    }
  }

  // ===== Connectivity probe (call once to verify) =====
  static Future<bool> testAPIConnection() async {
    try {
      print('[OpenAI] Testing… keyLen=${_apiKey.length}, model=$_model');
      final resp = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': 'Say "Hello" in one word.'},
              ],
              'max_tokens': 5,
            }),
          )
          .timeout(const Duration(seconds: 15));
      print('[OpenAI] Test status: ${resp.statusCode}');
      print('[OpenAI] Test body  : ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('[OpenAI] Test error: $e');
      return false;
    }
  }

  // ===== Fallbacks =====
  static UserProfile _fallbackFromAnswers(List<Map<String, String>> _) {
    return UserProfile(
      summary: 'Fallback: adaptive communicator.',
      traits: const ['Adaptive', 'Friendly'],
      tonePreferences: const ['Casual', 'Professional'],
      speakingStyle: 'Balanced',
      createdAt: DateTime.now(),
    );
  }

  static String _fallbackSingleResponse(
      String transcript, UserProfile? userProfile) {
    final t = transcript.toLowerCase();
    String response = "I understand.";

    if (t.contains('weather')) {
      response = "It might change later—do you prefer warm or cool days?";
    } else if (t.contains('?')) {
      response = "That's a good question. Let me think about that briefly.";
    }

    if (userProfile != null &&
        userProfile.speakingStyle.toLowerCase().contains('formal')) {
      response =
          response.replaceAll("I'm", "I am").replaceAll("don't", "do not");
    }
    return response;
  }
}
