class VoiceModel {
  final String id;
  final String name;
  final String gender; // 'male' or 'female'
  final String avatarPath;
  final double pitch;
  final double speechRate;
  final String voiceType; // 'warm', 'professional', 'friendly', 'casual'
  final String introduction; // Voice introduction message

  VoiceModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.avatarPath,
    required this.pitch,
    required this.speechRate,
    required this.voiceType,
    required this.introduction,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'avatarPath': avatarPath,
      'pitch': pitch,
      'speechRate': speechRate,
      'voiceType': voiceType,
      'introduction': introduction,
    };
  }

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      avatarPath: json['avatarPath'] ?? '',
      pitch: json['pitch']?.toDouble() ?? 1.0,
      speechRate: json['speechRate']?.toDouble() ?? 0.5,
      voiceType: json['voiceType'] ?? '',
      introduction: json['introduction'] ?? '',
    );
  }
}
