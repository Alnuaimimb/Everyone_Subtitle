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

  /// Generate dynamic option buttons and responses based on transcript
  static Future<Map<String, List<String>>> generateOptionButtons({
    required String transcript,
    UserProfile? userProfile,
  }) async {
    final keyLen = _useRemote ? (_apiKey.isNotEmpty ? _apiKey.length : 0) : 0;
    print('[OpenAI] useRemote=$_useRemote model=$_model keyLen=$keyLen');
    try {
      if (!_useRemote) return _fallbackOptionButtons(transcript, userProfile);

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
Based on the transcript, generate 2 option buttons (1-2 words each) and their corresponding responses.

Return ONLY a JSON object with this exact format:
{
  "buttons": ["button1", "button2"],
  "responses": ["response1", "response2"]
}

Transcript: "$transcript"

$profileInfo

Guidelines:
- Buttons should be 1-2 words (e.g., "Good", "Bad", "Agree", "Disagree", "Yes", "No")
- Responses should express YOUR OWN state/feeling/opinion based on the selected option
- For "How are you?" with "Good" button → Response: "I'm doing well, thank you for asking!"
- For "How are you?" with "Not great" button → Response: "I'm not feeling great today, but thank you for asking."
- For questions → Responses should be YOUR answer, not asking about someone else
- Make options relevant to the conversation context
- Ensure responses align with the user's personality profile
- Responses should be 1-2 sentences expressing YOUR perspective
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
                      'You generate option buttons and responses. Responses should express YOUR own state/opinion. Return ONLY JSON.'
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 200,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('[OpenAI] OptionButtons code=${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content =
            (data['choices']?[0]?['message']?['content'] ?? '') as String;
        if (content.trim().isNotEmpty) {
          return _parseOptionButtonsResponse(content);
        }
        print('[OpenAI] OptionButtons empty success body=${resp.body}');
        return _fallbackOptionButtons(transcript, userProfile);
      } else {
        print('[OpenAI] OptionButtons body=${resp.body}');
        return _fallbackOptionButtons(transcript, userProfile);
      }
    } catch (e) {
      print('[OpenAI] OptionButtons exception: $e');
      return _fallbackOptionButtons(transcript, userProfile);
    }
  }

  /// Generate a single short reply for the FinalResponse screen
  static Future<String> generateSingleResponse({
    required String transcript,
    UserProfile? userProfile,
    Map<String, String>? userInfo,
  }) async {
    final keyLen = _useRemote ? (_apiKey.isNotEmpty ? _apiKey.length : 0) : 0;
    print('[OpenAI] useRemote=$_useRemote model=$_model keyLen=$keyLen');
    try {
      if (!_useRemote) return _fallbackSingleResponse(transcript, userProfile, userInfo);

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

      final userInfoSection = (userInfo != null && userInfo.isNotEmpty)
          ? () {
              final b = StringBuffer();
              b.writeln('User Identity (use facts when relevant; do not invent):');
              userInfo.forEach((k, v) {
                if (v.trim().isNotEmpty) b.writeln('- $k: $v');
              });
              return b.toString();
            }()
          : 'User Identity: Not provided.';

      // Add randomization to ensure unique responses
      final randomVariations = [
        'Generate a unique and different response',
        'Create a fresh perspective on this',
        'Provide an alternative way to respond',
        'Give a new take on this conversation',
        'Offer a different viewpoint',
        'Respond with a unique angle',
        'Share a fresh thought on this',
        'Express this in a new way',
        'Give a different response than before',
        'Create a unique reply',
      ];

      final randomVariation = randomVariations[
          DateTime.now().millisecondsSinceEpoch % randomVariations.length];

      final prompt = '''
$randomVariation that matches the user style and the Style Guidelines exactly.

Transcript: "$transcript"

$profileInfo

$userInfoSection

Important: Make sure this response is different from any previous responses to the same transcript.
If the transcript asks about the user's personal details (e.g., name), use the provided User Identity. If a detail is not provided, do not fabricate it.
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
                      'You generate unique, varied replies aligned with the user style. Each response should be different. Return text only.'
                },
                {'role': 'user', 'content': prompt},
              ],
              // Higher temperature for more variety
              'temperature': 0.8,
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
        return _fallbackSingleResponse(transcript, userProfile, userInfo);
      } else {
        print('[OpenAI] SingleResp body=${resp.body}');
        return _fallbackSingleResponse(transcript, userProfile, userInfo);
      }
    } catch (e) {
      print('[OpenAI] SingleResp exception: $e');
      return _fallbackSingleResponse(transcript, userProfile, userInfo);
    }
  }

  // Build explicit style guidance so personality heavily influences the response.
  static String _buildStyleGuidelines(UserProfile profile) {
    final b = StringBuffer();
    final style = profile.speakingStyle.toLowerCase();
    if (style.contains('formal')) {
      b.writeln('- Formal tone; avoid contractions; precise wording.');
    } else if (style.contains('casual')) {
      b.writeln(
          "- Casual tone; contractions allowed (I'm, don't). Use approachable wording.");
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
    } else if (traits
        .any((t) => t.contains('diplomatic') || t.contains('warm'))) {
      b.writeln(
          '- Be diplomatic; use softeners like “could”, “would”, “let’s”.');
    }

    for (final t in profile.tonePreferences.map((e) => e.toLowerCase())) {
      if (t.contains('professional'))
        b.writeln('- Professional vocabulary; no slang.');
      if (t.contains('friendly')) b.writeln('- Friendly & warm phrasing.');
      if (t.contains('supportive'))
        b.writeln('- Supportive and encouraging tone.');
      if (t.contains('humor'))
        b.writeln('- Light, tasteful humor only if context allows.');
    }

    b.writeln('- 1–2 sentences only; plain language, accessible.');
    return b.toString().trim();
  }

  /// Quick probe to see exactly what OpenAI returns (call once at startup)
  static Future<void> debugProbe() async {
    try {
      final keyLen = _useRemote ? (_apiKey.isNotEmpty ? _apiKey.length : 0) : 0;
      print(
          '[OpenAI] probe: useRemote=$_useRemote model=$_model keyLen=$keyLen');
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

  static Map<String, List<String>> _parseOptionButtonsResponse(
      String response) {
    try {
      final s = response.indexOf('{');
      final e = response.lastIndexOf('}') + 1;
      final jsonString = response.substring(s, e);
      final data = jsonDecode(jsonString);

      return {
        'buttons': List<String>.from(data['buttons'] ?? const []),
        'responses': List<String>.from(data['responses'] ?? const []),
      };
    } catch (_) {
      return {
        'buttons': const [],
        'responses': const [],
      };
    }
  }

  static Map<String, List<String>> _fallbackOptionButtons(
      String transcript, UserProfile? userProfile) {
    final t = transcript.toLowerCase();
    final buttons = <String>[];
    final responses = <String>[];

    if (t.contains('how are you') || t.contains('how do you feel')) {
      buttons.add('Good');
      buttons.add('Not great');
      responses.add('I\'m doing well, thank you for asking!');
      responses.add('I\'m not feeling great today, but thank you for asking.');
    } else if (t.contains('weather')) {
      buttons.add('Warm');
      buttons.add('Cool');
      responses.add('I prefer warm weather, it makes me feel more energetic.');
      responses.add('I enjoy cool weather, it\'s refreshing and comfortable.');
    } else if (t.contains('?')) {
      buttons.add('Yes');
      buttons.add('No');
      responses.add('Yes, I think that\'s a good point.');
      responses.add('No, I don\'t think that\'s quite right.');
    } else if (t.contains('agree') || t.contains('think')) {
      buttons.add('Agree');
      buttons.add('Disagree');
      responses.add('I agree with that perspective.');
      responses.add('I disagree, I see it differently.');
    } else {
      // Default options for other contexts
      buttons.add('Good');
      buttons.add('Bad');
      responses.add('I think that\'s good.');
      responses.add('I think that\'s not ideal.');
    }

    // Apply user profile styling to responses
    if (userProfile != null) {
      final traits = userProfile.traits.map((e) => e.toLowerCase()).toList();
      final style = userProfile.speakingStyle.toLowerCase();

      for (int i = 0; i < responses.length; i++) {
        String response = responses[i];

        // Formal vs casual
        if (style.contains('formal')) {
          response = response
              .replaceAll("I'm", "I am")
              .replaceAll("don't", "do not")
              .replaceAll("that's", "that is");
        } else if (style.contains('casual')) {
          response = response
              .replaceAll("I am", "I'm")
              .replaceAll("do not", "don't")
              .replaceAll("that is", "that's");
        }

        // Apply personality traits
        if (traits
            .any((t) => t.contains('empathetic') || t.contains('caring'))) {
          if (!response.toLowerCase().contains('thank you')) {
            response =
                response.replaceFirst('.', ', and I appreciate you asking.');
          }
        }
        if (traits
            .any((t) => t.contains('assertive') || t.contains('confident'))) {
          response = response.replaceAll('I think ', '');
          response = response.replaceAll('maybe', '');
        }
        if (traits.any((t) => t.contains('direct'))) {
          response = response.replaceAll('I think ', '');
        }
        if (userProfile.tonePreferences
            .any((t) => t.toLowerCase().contains('professional'))) {
          response = response.replaceAll('!', '.');
        }

        responses[i] = response;
      }
    }

    return {
      'buttons': buttons,
      'responses': responses,
    };
  }

  static String _fallbackSingleResponse(
      String transcript, UserProfile? userProfile, Map<String, String>? userInfo) {
    final t = transcript.toLowerCase();

    // Add variety to fallback responses
    final responses = <String>[];

    if (t.contains('how are you') || t.contains('how do you feel')) {
      responses.addAll([
        "I'm doing well, thank you for asking!",
        "I'm feeling great today, thanks!",
        "I'm in a good mood, how about you?",
        "I'm doing fine, appreciate you asking.",
        "I'm feeling positive today!",
      ]);
    } else if (t.contains('weather')) {
      responses.addAll([
        "The weather can be quite unpredictable, don't you think?",
        "I find weather discussions fascinating.",
        "Weather always affects my mood.",
        "I enjoy talking about the weather.",
      ]);
    } else if (t.contains('your name') || t.contains("what's your name") || t.contains('whats your name') || t.contains('who are you')) {
      final name = (userInfo != null && (userInfo['FirstName']?.isNotEmpty == true))
          ? userInfo['FirstName']
          : null;
      if (name != null) {
        responses.addAll([
          "I'm $name.",
          "My name is $name.",
          "$name.",
        ]);
      } else {
        responses.addAll([
          "I'd rather not say.",
          "I'd prefer to keep that private.",
        ]);
      }
    } else if (t.contains('?')) {
      responses.addAll([
        "That's an interesting question to consider.",
        "I appreciate you asking that.",
        "That's something worth thinking about.",
        "Good question, let me reflect on that.",
      ]);
    } else if (t.contains('agree') || t.contains('think')) {
      responses.addAll([
        "I see your point on that.",
        "That's a valid perspective.",
        "I understand where you're coming from.",
        "That makes sense to me.",
      ]);
    } else {
      responses.addAll([
        "I understand what you're saying.",
        "That's an interesting point.",
        "I appreciate you sharing that.",
        "That's worth considering.",
        "I see what you mean.",
      ]);
    }

    // Select a random response based on current time
    final selectedResponse =
        responses[DateTime.now().millisecondsSinceEpoch % responses.length];

    if (userProfile != null) {
      // Apply user profile styling
      String response = selectedResponse;

      // Formal vs casual
      if (userProfile.speakingStyle.toLowerCase().contains('formal')) {
        response = response
            .replaceAll("I'm", "I am")
            .replaceAll("don't", "do not")
            .replaceAll("that's", "that is");
      } else if (userProfile.speakingStyle.toLowerCase().contains('casual')) {
        response = response
            .replaceAll("I am", "I'm")
            .replaceAll("do not", "don't")
            .replaceAll("that is", "that's");
      }

      final traits = userProfile.traits.map((e) => e.toLowerCase()).toList();
      if (traits.any((t) => t.contains('empathetic') || t.contains('caring'))) {
        if (!response.toLowerCase().contains('i understand')) {
          response = 'I understand. ' + response;
        }
      }
      if (traits
          .any((t) => t.contains('assertive') || t.contains('confident'))) {
        response = response.replaceAll('maybe', '');
        if (!response.toLowerCase().startsWith("let's") &&
            !response.toLowerCase().startsWith('i will')) {
          response = "Let's " +
              response.replaceFirst(RegExp('^(I )', caseSensitive: false), '');
        }
      }
      if (traits.any((t) => t.contains('direct'))) {
        response = response.replaceAll('I think ', '');
      }
      if (userProfile.tonePreferences
          .any((t) => t.toLowerCase().contains('professional'))) {
        response = response.replaceAll('!', '.');
      }

      return response;
    }

    return selectedResponse;
  }
}
