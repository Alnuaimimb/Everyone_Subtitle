import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String _readRequired(String key) {
    final fromDotEnv = dotenv.env[key];
    if (fromDotEnv != null && fromDotEnv.isNotEmpty) return fromDotEnv;
    // Workaround for const-fromEnvironment at runtime: use switch
    switch (key) {
      case 'OPENAI_API_KEY':
        const v = String.fromEnvironment('OPENAI_API_KEY');
        if (v.isNotEmpty) return v;
        break;
      case 'ASSEMBLYAI_API_KEY':
        const v = String.fromEnvironment('ASSEMBLYAI_API_KEY');
        if (v.isNotEmpty) return v;
        break;
      case 'API_BASE_URL':
        const v = String.fromEnvironment('API_BASE_URL');
        if (v.isNotEmpty) return v;
        break;
    }
    throw Exception('Missing required env: $key');
  }

  static String get openaiApiKey => _readRequired('OPENAI_API_KEY');
  static String get assemblyAIKey => _readRequired('ASSEMBLYAI_API_KEY');
  static String get apiBaseUrl => _readRequired('API_BASE_URL');

  static bool get enableOpenAI {
    final v = dotenv.env['ENABLE_OPENAI'];
    if (v != null) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return bool.fromEnvironment('ENABLE_OPENAI', defaultValue: true);
  }
}

