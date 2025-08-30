import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';
import 'package:everyone_subtitle/utils/constants/api.dart';

class OpenAIService {
  // Endpoint & model (stable)
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  // Enable/disable remote calls via build flag (default = true)
  // Example: flutter run --dart-define=ENABLE_OPENAI=true
  static bool get _useRemote => Env.enableOpenAI && Env.hasOpenAIKey;

  // API key is provided via .env or --dart-define
  static String get _apiKey => Env.openaiApiKeyOrNull ?? '';

  // ====================== PUBLIC API ======================

  /// Build a user profile from quiz answers (calls OpenAI, falls back if needed)
  static Future<UserProfile> generateUserProfile(
      List<Map<String, String>> answers) async {
    final keyLen = _useRemote ? (_apiKey.isNotEmpty ? _apiKey.length : 0) : 0;
    print('[OpenAI] useRemote=$_useRemote model=$_model keyLen=$keyLen');
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

      print('[OpenAI] Profile code=${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content =
            (data['choices']?[0]?['message']?['content'] ?? '') as String;
        return _parseProfileFromResponse(content);
      } else {
        print('[OpenAI] Profile body=${resp.body}');
        return _fallbackFromAnswers(answers);
      }
    } catch (e) {
      print('[OpenAI] Profile exception: $e');
      return _fallbackFromAnswers(answers);
    }
  }

  /// Generate a single short reply for the FinalResponse screen
  static Future<String> generateSingleResponse({
    required String transcript,
    UserProfile? userProfile,
  }) async {
    final keyLen = _useRemote ? (_apiKey.isNotEmpty ? _apiKey.length : 0) : 0;
    print('[OpenAI] useRemote=$_useRemote model=$_model keyLen=$keyLen');
    try {
      if (!_useRemote) return _fallbackSingleResponse(transcript, userProfile);

      final profileInfo = userProfile != null
          ? '''
User Profile:
- Summary: ${userProfile.summary}
- Traits: ${userProfile.traits.join(', ')}
- Style: ${userProfile.speakingStyle}
- Tones: ${userProfile.tonePreferences.join(', ')}
 
Style Guidelines (follow strictly):
${_buildStyleGuidelines(userProfile)}
'''
          : 'No profile available.';

      final prompt = '''
Return ONLY a 1–2 sentence reply that matches the user style and the Style Guidelines exactly.

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
              // Lower temperature to adhere more closely to style constraints
              'temperature': 0.5,
              'max_tokens': 120,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('[OpenAI] SingleResp code=${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content =
            (data['choices']?[0]?['message']?['content'] ?? '') as String;
        if (content.trim().isNotEmpty) return content.trim();
        print('[OpenAI] SingleResp empty success body=${resp.body}');
        return _fallbackSingleResponse(transcript, userProfile);
      } else {
        print('[OpenAI] SingleResp body=${resp.body}');
        return _fallbackSingleResponse(transcript, userProfile);
      }
    } catch (e) {
      print('[OpenAI] SingleResp exception: $e');
      return _fallbackSingleResponse(transcript, userProfile);
    }
  }

  // Build explicit style guidance so personality heavily influences the response.
  static String _buildStyleGuidelines(UserProfile profile) {
    final b = StringBuffer();
    final style = profile.speakingStyle.toLowerCase();
    if (style.contains('formal')) {
      b.writeln('- Formal tone; avoid contractions; precise wording.');
    } else if (style.contains('casual')) {
      b.writeln("- Casual tone; contractions allowed (I'm, don't). Use approachable wording.");
    } else {
      b.writeln('- Neutral tone; prioritize clarity and brevity.');
    }

    final traits = profile.traits.map((t) => t.toLowerCase()).toList();
    if (traits.any((t) => t.contains('empathetic') || t.contains('caring'))) {
      b.writeln('- Show empathy briefly (e.g., “I understand”, “I hear you”).');
    }
    if (traits.any((t) => t.contains('assertive') || t.contains('confident'))) {
      b.writeln('- Be assertive; avoid hedging like “maybe” or “I guess”.');
    }
    if (traits.any((t) => t.contains('direct'))) {
      b.writeln('- Be direct; get to the point quickly.');
    } else if (traits.any((t) => t.contains('diplomatic') || t.contains('warm'))) {
      b.writeln('- Be diplomatic; use softeners like “could”, “would”, “let’s”.');
    }

    for (final t in profile.tonePreferences.map((e) => e.toLowerCase())) {
      if (t.contains('professional')) b.writeln('- Professional vocabulary; no slang.');
      if (t.contains('friendly')) b.writeln('- Friendly & warm phrasing.');
      if (t.contains('supportive')) b.writeln('- Supportive and encouraging tone.');
      if (t.contains('humor')) b.writeln('- Light, tasteful humor only if context allows.');
    }

    b.writeln('- 1–2 sentences only; plain language, accessible.');
    return b.toString().trim();
  }

  /// Quick probe to see exactly what OpenAI returns (call once at startup)
  static Future<void> debugProbe() async {
    try {
      final keyLen = _useRemote ? (_apiKey.isNotEmpty ? _apiKey.length : 0) : 0;
      print('[OpenAI] probe: useRemote=$_useRemote model=$_model keyLen=$keyLen');
      final r = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': 'ping'},
              ],
              'max_tokens': 5,
            }),
          )
          .timeout(const Duration(seconds: 30));
      print('[OpenAI] probe code=${r.statusCode}');
      print('[OpenAI] probe body=${r.body}');
    } catch (e) {
      print('[OpenAI] probe error=$e');
    }
  }

  /// Boolean-style connectivity check (optional)
  static Future<bool> testAPIConnection() async {
    try {
      final r = await http
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
      print('[OpenAI] Test code=${r.statusCode}');
      print('[OpenAI] Test body=${r.body}');
      return r.statusCode == 200;
    } catch (e) {
      print('[OpenAI] Test error=$e');
      return false;
    }
  }

  // ====================== INTERNALS ======================

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

    if (userProfile != null) {
      // Formal vs casual
      if (userProfile.speakingStyle.toLowerCase().contains('formal')) {
        response = response
            .replaceAll("I'm", "I am")
            .replaceAll("don't", "do not");
      } else if (userProfile.speakingStyle.toLowerCase().contains('casual')) {
        response = response
            .replaceAll("I am", "I'm")
            .replaceAll("do not", "don't");
      }

      final traits = userProfile.traits.map((e) => e.toLowerCase()).toList();
      if (traits.any((t) => t.contains('empathetic') || t.contains('caring'))) {
        if (!response.toLowerCase().contains('i understand')) {
          response = 'I understand. ' + response;
        }
      }
      if (traits.any((t) => t.contains('assertive') || t.contains('confident'))) {
        response = response.replaceAll('maybe', '');
        if (!response.toLowerCase().startsWith("let's") &&
            !response.toLowerCase().startsWith('i will')) {
          response = "Let's " + response.replaceFirst(RegExp('^(I )', caseSensitive: false), '');
        }
      }
      if (traits.any((t) => t.contains('direct'))) {
        response = response.replaceAll('I think ', '');
      }
      if (userProfile.tonePreferences.any((t) => t.toLowerCase().contains('professional'))) {
        response = response.replaceAll('!', '.');
      }
    }
    return response;
  }
}
