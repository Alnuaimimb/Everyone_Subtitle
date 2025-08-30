import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // Case-insensitive and optional lookup from .env
  static String? _readOptionalCI(String key) {
    final direct = dotenv.env[key];
    if (direct != null && direct.isNotEmpty) return direct;
    final lower = key.toLowerCase();
    for (final entry in dotenv.env.entries) {
      if (entry.key.toLowerCase() == lower && entry.value.isNotEmpty) {
        return entry.value;
      }
    }
    return null;
  }

  static String _readRequired(String key) {
    final fromDotEnv = _readOptionalCI(key);
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

  // Strict reads (throw if missing)
  static String get openaiApiKey => _readRequired('OPENAI_API_KEY');
  static String get apiBaseUrl => _readRequired('API_BASE_URL');

  // Soft reads (nullable, do not throw)
  static String? get assemblyAIKeyOrNull {
    final v = _readOptionalCI('ASSEMBLYAI_API_KEY');
    if (v != null && v.isNotEmpty) return v;
    const dv = String.fromEnvironment('ASSEMBLYAI_API_KEY');
    return dv.isNotEmpty ? dv : null;
  }
  static bool get hasAssemblyAIKey => (assemblyAIKeyOrNull?.isNotEmpty ?? false);

  static String? get openaiApiKeyOrNull {
    final v = _readOptionalCI('OPENAI_API_KEY');
    if (v != null && v.isNotEmpty) return v;
    const dv = String.fromEnvironment('OPENAI_API_KEY');
    return dv.isNotEmpty ? dv : null;
  }
  static bool get hasOpenAIKey => (openaiApiKeyOrNull?.isNotEmpty ?? false);

  static bool get enableOpenAI {
    final v = _readOptionalCI('ENABLE_OPENAI');
    if (v != null) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return bool.fromEnvironment('ENABLE_OPENAI', defaultValue: true);
  }

  static bool get enableTranscription {
    final v = _readOptionalCI('ENABLE_TRANSCRIPTION');
    if (v != null) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    // Default to true only if we have a key
    return hasAssemblyAIKey;
  }
}
