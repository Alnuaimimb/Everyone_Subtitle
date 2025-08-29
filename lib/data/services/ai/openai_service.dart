import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-3.5-turbo';
  // Toggle remote API calls at build-time. Default true so API is used when a key is set.
  static const bool _useRemote =
      bool.fromEnvironment('ENABLE_OPENAI', defaultValue: true);

  // Get API key from environment or build config
  static String get _apiKey {
    // First try build-time define
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isNotEmpty) {
      return apiKey;
    }
    // Hardcoded development key (as requested). Do NOT ship this to prod builds.
    const hardcoded =
        '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';
    return hardcoded;
  }

  static Future<UserProfile> generateUserProfile(
      List<Map<String, String>> answers) async {
    try {
      // Fast path: local profile when remote is disabled
      if (!_useRemote) {
        // ignore: avoid_print
        print('[OpenAI] generateUserProfile: remote disabled, using fallback');
        return _fallbackFromAnswers(answers);
      }
      final prompt = _buildPrompt(answers);

      final response = await http
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
                      'You are a personality analysis expert. Analyze the quiz answers and create a concise user profile in JSON format.',
                },
                {
                  'role': 'user',
                  'content': prompt,
                },
              ],
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseProfileFromResponse(content);
      } else {
        // Graceful fallback for quota/network errors
        if (response.statusCode == 429 ||
            response.statusCode == 401 ||
            response.statusCode == 403 ||
            response.statusCode >= 500) {
          // ignore: avoid_print
          print(
              '[OpenAI] generateUserProfile: API ${response.statusCode}, using fallback');
          return _fallbackFromAnswers(answers);
        }
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      // Any exception (timeout, parsing, connectivity) => fallback
      // ignore: avoid_print
      print('[OpenAI] generateUserProfile: exception, using fallback -> $e');
      return _fallbackFromAnswers(answers);
    }
  }

  static String _buildPrompt(List<Map<String, String>> answers) {
    final answersText = answers
        .map((a) => 'Q: ${a['question']}\nA: ${a['answer']}')
        .join('\n\n');

    return '''
Based on the following personality quiz answers, create a concise user profile in JSON format:

$answersText

Please analyze these answers and return a JSON object with the following structure:
{
  "summary": "A 2-3 sentence summary of the person's communication style and personality",
  "traits": ["trait1", "trait2", "trait3", "trait4"],
  "tone_preferences": ["preference1", "preference2", "preference3"],
  "speaking_style": "Brief description of how they prefer to communicate"
}

Focus on communication style, empathy level, assertiveness, and social preferences. Keep the summary concise and actionable for generating personalized responses.
''';
  }

  static UserProfile _parseProfileFromResponse(String response) {
    try {
      // Extract JSON from response (in case there's extra text)
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      final jsonString = response.substring(jsonStart, jsonEnd);

      final data = jsonDecode(jsonString);

      return UserProfile(
        summary: data['summary'] ?? 'No summary available',
        traits: List<String>.from(data['traits'] ?? []),
        tonePreferences: List<String>.from(data['tone_preferences'] ?? []),
        speakingStyle: data['speaking_style'] ?? 'Standard',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // Fallback profile if parsing fails
      return UserProfile(
        summary: 'Unable to generate profile from quiz answers.',
        traits: ['Adaptable', 'Communicative'],
        tonePreferences: ['Professional', 'Friendly'],
        speakingStyle: 'Balanced',
        createdAt: DateTime.now(),
      );
    }
  }

  // Simple offline heuristic to create a usable profile when API is unavailable.
  static UserProfile _fallbackFromAnswers(List<Map<String, String>> answers) {
    final text =
        answers.map((e) => (e['answer'] ?? '').toLowerCase()).join(' ');

    int score(String word) => RegExp('\\b$word\\b').allMatches(text).length;

    final isSocial = score('team') + score('friends') + score('social') >
        score('alone') + score('solo');
    final isDirect = score('direct') + score('honest') > score('diplomatic');
    final isPlanner = score('plan') + score('schedule') > score('spontaneous');
    final isEmpathetic = score('empathy') + score('listening') > 0;
    final isAssertive = score('confident') + score('assertive') > 0;

    final traits = <String>{};
    if (isSocial)
      traits.add('Social');
    else
      traits.add('Independent');
    if (isPlanner)
      traits.add('Organized');
    else
      traits.add('Flexible');
    if (isEmpathetic) traits.add('Empathetic');
    if (isAssertive) traits.add('Assertive');
    if (isDirect)
      traits.add('Direct Communicator');
    else
      traits.add('Diplomatic');

    final tone = <String>[
      if (isDirect) 'Direct' else 'Warm',
      if (isPlanner) 'Structured' else 'Casual',
      if (isEmpathetic) 'Empathetic' else 'Professional',
    ];

    final speakingStyle = [
      isDirect ? 'Clear' : 'Friendly',
      isPlanner ? 'Structured' : 'Conversational',
      isSocial ? 'Engaging' : 'Concise',
    ].join(', ');

    final summary = isSocial
        ? 'Friendly, ${isPlanner ? 'organized' : 'flexible'} communicator who enjoys collaboration.'
        : 'Calm, ${isPlanner ? 'organized' : 'flexible'} communicator who values efficiency.';

    return UserProfile(
      summary: summary,
      traits: traits.toList(),
      tonePreferences: tone,
      speakingStyle: speakingStyle,
      createdAt: DateTime.now(),
    );
  }

  // Generate personalized response options based on transcript and user profile
  static Future<Map<String, String>> generateResponseOptions({
    required String transcript,
    UserProfile? userProfile,
  }) async {
    try {
      // ignore: avoid_print
      print(
          '[OpenAI] generateResponseOptions: starting with transcript: "$transcript"');
      print('[OpenAI] _useRemote: $_useRemote');

      // Fast path: local generation when remote is disabled
      if (!_useRemote) {
        // ignore: avoid_print
        print(
            '[OpenAI] generateResponseOptions: remote disabled, using fallback');
        return _fallbackResponseOptions(transcript, userProfile);
      }

      final prompt = _buildResponsePrompt(transcript, userProfile);

      // ignore: avoid_print
      print('[OpenAI] API key length: ${_apiKey.length}');
      print('[OpenAI] API key starts with: ${_apiKey.substring(0, 10)}...');

      final response = await http
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
                      'You are a communication assistant that generates personalized response options based on user personality and speech content.',
                },
                {
                  'role': 'user',
                  'content': prompt,
                },
              ],
              'temperature': 0.8,
              'max_tokens': 300,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // ignore: avoid_print
        print('[OpenAI] content => ' + content.toString());
        return _parseResponseOptions(content);
      } else {
        // Graceful fallback for API errors
        // ignore: avoid_print
        print(
            '[OpenAI] generateResponseOptions: API ${response.statusCode}, response body: ${response.body}, using fallback');
        return _fallbackResponseOptions(transcript, userProfile);
      }
    } catch (e) {
      // Any exception => fallback
      // ignore: avoid_print
      print(
          '[OpenAI] generateResponseOptions: exception, using fallback -> $e');
      return _fallbackResponseOptions(transcript, userProfile);
    }
  }

  static String _buildResponsePrompt(
      String transcript, UserProfile? userProfile) {
    final profileInfo = userProfile != null
        ? '''
User Profile:
- Summary: ${userProfile.summary}
- Traits: ${userProfile.traits.join(', ')}
- Speaking Style: ${userProfile.speakingStyle}
- Tone Preferences: ${userProfile.tonePreferences.join(', ')}
'''
        : 'No user profile available.';

    return '''
Based on the following transcript and user profile, generate personalized response options:

Transcript: "$transcript"

$profileInfo

Please return a JSON object with EXACTLY these fields:
{
  "optionA": "1–3 word title for the first option reflecting intent",
  "optionB": "1–3 word title for the second option reflecting intent",
  "responseA": "Full response text for option A (1–2 sentences)",
  "responseB": "Full response text for option B (1–2 sentences)"
}

Constraints:
- Titles must not be generic like 'Greet', 'Greeting', 'Ask', or 'Ask back'.
- Titles must vary with the transcript topic (e.g., Confirm/Reschedule, Support/Clarify, Answer/Follow‑up).
- Responses should match the user's speaking style and be concise.
Return only the JSON object — no extra commentary.
''';
  }

  static Map<String, String> _parseResponseOptions(String response) {
    try {
      // Extract JSON from response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      final jsonString = response.substring(jsonStart, jsonEnd);

      final data = jsonDecode(jsonString);

      return _postProcessTitles({
        'optionA': data['optionA'] ?? 'Agree',
        'optionB': data['optionB'] ?? 'Disagree',
        'responseA': data['responseA'] ?? 'I understand what you\'re saying.',
        'responseB': data['responseB'] ?? 'Could you clarify a bit more?',
      });
    } catch (e) {
      // Try a relaxed extraction if strict JSON parsing failed
      try {
        final cleaned = response
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .replaceAll('\r', '')
            .trim();

        final dynamic data = jsonDecode(cleaned);
        if (data is Map) {
          String pick(List<String> keys, String fallback) {
            for (final k in keys) {
              final v = data[k];
              if (v is String && v.trim().isNotEmpty) return v;
            }
            return fallback;
          }

          final result = {
            'optionA':
                pick(['optionA', 'titleA', 'option_a', 'title_a'], 'Agree'),
            'optionB':
                pick(['optionB', 'titleB', 'option_b', 'title_b'], 'Disagree'),
            'responseA': pick(['responseA', 'response_a', 'a'],
                "I understand what you're saying."),
            'responseB': pick(['responseB', 'response_b', 'b'],
                'Could you clarify a bit more?'),
          };
          return _postProcessTitles(result);
        }
      } catch (_) {
        // ignore and fall through to default below
      }

      // Fallback if parsing fails
      return _postProcessTitles({
        'optionA': 'Agree',
        'optionB': 'Disagree',
        'responseA': "I understand what you're saying.",
        'responseB': 'I see it differently; could we consider alternatives?',
      });
    }
  }

  // Normalize and sanitize titles coming from the model (or relaxed parser)
  static Map<String, String> _postProcessTitles(Map<String, String> m) {
    String sanitize(String? s, String fallback) {
      if (s == null || s.trim().isEmpty) return fallback;
      final lower = s.trim().toLowerCase();
      const banned = {'greet', 'greeting', 'ask back', 'ask'};
      String title = banned.contains(lower)
          ? (lower.contains('ask') ? 'Follow-up' : 'Acknowledge')
          : s.trim();
      // Title case 1–3 words
      final parts = title.split(RegExp(r'[\s_\-]+')).where((w) => w.isNotEmpty);
      title = parts
          .map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : ''))
          .take(3)
          .join(' ');
      return title;
    }

    return {
      'optionA': sanitize(m['optionA'], 'Option A'),
      'optionB': sanitize(m['optionB'], 'Option B'),
      'responseA': m['responseA'] ?? "I understand what you're saying.",
      'responseB': m['responseB'] ?? 'Could you clarify a bit more?',
    };
  }

  static Map<String, String> _fallbackResponseOptions(
      String transcript, UserProfile? userProfile) {
    // Heuristic fallback generation so results change with the transcript
    final t = transcript.toLowerCase();

    // ignore: avoid_print
    print('[OpenAI] Using fallback for transcript: "$transcript"');

    String optionA = 'Agree';
    String optionB = 'Disagree';
    String responseA = 'I understand what you\'re saying.';
    String responseB = 'I see your point, but I have some concerns.';

    // Check for greetings first (before questions)
    bool isGreeting = t.contains('hello') ||
        t.contains('hi ') ||
        t.contains('hey') ||
        t.startsWith('how are you') ||
        t.contains('good morning') ||
        t.contains('good afternoon') ||
        t.contains('good evening') ||
        t.contains('how\'s it going') ||
        t.contains('what\'s up');

    bool hasQuestion = t.contains('?') ||
        t.contains('could you') ||
        t.contains('can you') ||
        t.contains('would you') ||
        (t.startsWith('how ') && !t.startsWith('how are you')) ||
        t.startsWith('what ') ||
        t.startsWith('why ');
    bool isThanks = t.contains('thank') || t.contains('appreciate');
    bool isApology = t.contains('sorry') || t.contains('apolog');
    bool scheduling =
        t.contains('meeting') || t.contains('schedule') || t.contains('time');
    bool problem = t.contains('problem') ||
        t.contains('issue') ||
        t.contains('error') ||
        t.contains('wrong');
    bool delay = t.contains('late') || t.contains('delay');
    bool price = t.contains('price') || t.contains('cost');

    if (isGreeting) {
      optionA = 'Welcome';
      optionB = 'Connect';
      responseA = 'Hi! Great to hear from you — how are you today?';
      responseB = 'Hello! Hope you\'re doing well — what\'s on your mind?';
    } else if (scheduling) {
      optionA = 'Confirm';
      optionB = 'Reschedule';
      responseA = 'That timing works for me. Let\'s confirm the details.';
      responseB = 'I\'m not available then; could we pick another time?';
    } else if (problem) {
      optionA = 'Support';
      optionB = 'Clarify';
      responseA = 'I understand the issue and I\'m here to help resolve it.';
      responseB = 'Could you share a few more details so I can help better?';
    } else if (hasQuestion) {
      optionA = 'Answer';
      optionB = 'Follow‑up';
      responseA = 'Here\'s what I think: based on what you shared…';
      responseB = 'Good question — could you clarify a little more about…';
    } else if (isThanks) {
      optionA = 'Welcome';
      optionB = 'Humble';
      responseA = 'You\'re very welcome — happy to help!';
      responseB = 'Thanks, I appreciate it. Glad it helped.';
    } else if (isApology || delay) {
      optionA = 'Apologize';
      optionB = 'Explain';
      responseA =
          'I\'m sorry about that. I\'ll make sure it doesn\'t happen again.';
      responseB = 'Thanks for your patience — here\'s what caused the delay…';
    } else if (price) {
      optionA = 'Offer';
      optionB = 'Discuss';
      responseA = 'We can offer a fair rate. Let\'s align on budget and scope.';
      responseB = 'Happy to discuss pricing — what range did you have in mind?';
    } else if (t.contains('weather') ||
        t.contains('cold') ||
        t.contains('hot') ||
        t.contains('rain')) {
      optionA = 'Empathize';
      optionB = 'Suggest';
      responseA =
          'I know how that feels! The weather can really affect our mood.';
      responseB =
          'Maybe we can find something to brighten your day despite the weather.';
    } else if (t.contains('work') ||
        t.contains('job') ||
        t.contains('office')) {
      optionA = 'Support';
      optionB = 'Advise';
      responseA =
          'Work can be challenging sometimes. I hope your day gets better.';
      responseB =
          'Is there anything specific about work that\'s bothering you?';
    } else if (t.contains('family') ||
        t.contains('kids') ||
        t.contains('children')) {
      optionA = 'Relate';
      optionB = 'Ask';
      responseA = 'Family is so important. How are they doing?';
      responseB = 'That sounds wonderful! Tell me more about your family.';
    } else if (t.contains('food') ||
        t.contains('eat') ||
        t.contains('hungry') ||
        t.contains('dinner')) {
      optionA = 'Share';
      optionB = 'Recommend';
      responseA =
          'Food is one of life\'s great pleasures! What are you thinking of having?';
      responseB = 'I love trying new foods too! Any favorite cuisines?';
    }

    // Apply personality if available
    if (userProfile != null) {
      if (userProfile.speakingStyle.toLowerCase().contains('formal')) {
        responseA =
            responseA.replaceAll("I'm", "I am").replaceAll("don't", "do not");
        responseB =
            responseB.replaceAll("I'm", "I am").replaceAll("don't", "do not");
      } else if (userProfile.speakingStyle.toLowerCase().contains('casual')) {
        responseA =
            responseA.replaceAll("I am", "I'm").replaceAll("do not", "don't");
        responseB =
            responseB.replaceAll("I am", "I'm").replaceAll("do not", "don't");
      }

      // Add empathetic phrases for empathetic users
      if (userProfile.traits.any((trait) =>
          trait.toLowerCase().contains('empathetic') ||
          trait.toLowerCase().contains('caring'))) {
        if (isGreeting &&
            !responseA.contains('hope') &&
            !responseA.contains('wish')) {
          responseA = responseA.replaceFirst('How are you?',
              'How are you? I hope you\'re having a great day!');
          responseB = responseB.replaceFirst('How about you?',
              'How about you? I hope everything is going well!');
        }
      }
    }

    return {
      'optionA': optionA,
      'optionB': optionB,
      'responseA': responseA,
      'responseB': responseB,
    };
  }

  // Test method to verify API connectivity
  static Future<bool> testAPIConnection() async {
    try {
      print('[OpenAI] Testing API connection...');
      print('[OpenAI] API key length: ${_apiKey.length}');
      print('[OpenAI] API key starts with: ${_apiKey.substring(0, 10)}...');

      final response = await http
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
                  'role': 'user',
                  'content': 'Say "Hello"',
                },
              ],
              'max_tokens': 10,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('[OpenAI] Test response status: ${response.statusCode}');
      print('[OpenAI] Test response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('[OpenAI] Test API connection failed: $e');
      return false;
    }
  }
}
