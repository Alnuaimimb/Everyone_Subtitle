import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-3.5-turbo';
  // Toggle remote API calls at build-time. Defaults to false for fast local generation.
  static const bool _useRemote =
      bool.fromEnvironment('ENABLE_OPENAI', defaultValue: false);

  // Get API key from environment or build config
  static String get _apiKey {
    // First try build-time define
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isNotEmpty) {
      return apiKey;
    }

    // Fallback to hardcoded key for development (remove in production)
    const fallbackKey =
        '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';
    if (fallbackKey.isNotEmpty && fallbackKey != 'your_api_key_here') {
      return fallbackKey;
    }

    throw Exception(
        'OPENAI_API_KEY not found. Please set it using --dart-define=OPENAI_API_KEY=your_key');
  }

  static Future<UserProfile> generateUserProfile(
      List<Map<String, String>> answers) async {
    try {
      // Fast path: local profile when remote is disabled
      if (!_useRemote) {
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
          return _fallbackFromAnswers(answers);
        }
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      // Any exception (timeout, parsing, connectivity) => fallback
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
      // Fast path: local generation when remote is disabled
      if (!_useRemote) {
        return _fallbackResponseOptions(transcript, userProfile);
      }

      final prompt = _buildResponsePrompt(transcript, userProfile);

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
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseResponseOptions(content);
      } else {
        // Graceful fallback for API errors
        return _fallbackResponseOptions(transcript, userProfile);
      }
    } catch (e) {
      // Any exception => fallback
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

Please return a JSON object with:
{
  "optionA": "Short title for first response option (e.g., 'Agree', 'Supportive')",
  "optionB": "Short title for second response option (e.g., 'Disagree', 'Question')",
  "responseA": "Full response text for option A, personalized to the user's style",
  "responseB": "Full response text for option B, personalized to the user's style"
}

Make the response natural and match the user's personality traits and speaking style.
''';
  }

  static Map<String, String> _parseResponseOptions(String response) {
    try {
      // Extract JSON from response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      final jsonString = response.substring(jsonStart, jsonEnd);

      final data = jsonDecode(jsonString);

      return {
        'optionA': data['optionA'] ?? 'Agree',
        'optionB': data['optionB'] ?? 'Disagree',
        'responseA': data['responseA'] ?? 'I understand what you\'re saying.',
        'responseB': data['responseB'] ?? 'Could you clarify a bit more?',
      };
    } catch (e) {
      // Fallback if parsing fails
      return {
        'optionA': 'Agree',
        'optionB': 'Disagree',
        'responseA': 'I understand what you\'re saying.',
        'responseB': 'I see it differently; could we consider alternatives?',
      };
    }
  }

  static Map<String, String> _fallbackResponseOptions(
      String transcript, UserProfile? userProfile) {
    // Simple fallback response generation
    final transcriptLower = transcript.toLowerCase();

    String optionA = 'Agree';
    String optionB = 'Disagree';
    String responseA = 'I understand what you\'re saying.';
    String responseB = 'I see your point, but I have some concerns.';

    // Simple logic based on transcript content
    if (transcriptLower.contains('meeting') ||
        transcriptLower.contains('schedule')) {
      optionA = 'Confirm';
      optionB = 'Reschedule';
      responseA = 'That schedule works for me. Let\'s confirm the time.';
      responseB = 'I\'m unavailable at that time; could we reschedule?';
    } else if (transcriptLower.contains('problem') ||
        transcriptLower.contains('issue')) {
      optionA = 'Support';
      optionB = 'Question';
      responseA = 'I understand the issue you\'re facing and I\'m here to help.';
      responseB = 'Could you share a bit more detail so I can help better?';
    } else if (transcriptLower.contains('thank') ||
        transcriptLower.contains('appreciate')) {
      optionA = 'Welcome';
      optionB = 'Humble';
      responseA = 'You\'re very welcome! Happy to help.';
      responseB = 'I appreciate it. Glad I could help.';
    }

    // Apply personality if available
    if (userProfile != null) {
      if (userProfile.speakingStyle.toLowerCase().contains('formal')) {
        responseA = responseA
            .replaceAll("I'm", "I am").replaceAll("don't", "do not");
        responseB = responseB
            .replaceAll("I'm", "I am").replaceAll("don't", "do not");
      } else if (userProfile.speakingStyle.toLowerCase().contains('casual')) {
        responseA = responseA
            .replaceAll("I am", "I'm").replaceAll("do not", "don't");
        responseB = responseB
            .replaceAll("I am", "I'm").replaceAll("do not", "don't");
      }
    }

    return {
      'optionA': optionA,
      'optionB': optionB,
      'responseA': responseA,
      'responseB': responseB,
    };
  }
}
