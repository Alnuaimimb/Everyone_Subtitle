class UserProfile {
  final String summary;
  final List<String> traits;
  final List<String> tonePreferences;
  final String speakingStyle;
  final DateTime createdAt;

  UserProfile({
    required this.summary,
    required this.traits,
    required this.tonePreferences,
    required this.speakingStyle,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      summary: json['summary'] ?? '',
      traits: List<String>.from(json['traits'] ?? []),
      tonePreferences: List<String>.from(json['tone_preferences'] ?? []),
      speakingStyle: json['speaking_style'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'traits': traits,
      'tone_preferences': tonePreferences,
      'speaking_style': speakingStyle,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
