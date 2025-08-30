import 'package:everyone_subtitle/Features/voice/models/voice_model.dart';
import 'package:everyone_subtitle/utils/constants/image_strings.dart';

class VoiceConstants {
  static List<VoiceModel> availableVoices = [
    VoiceModel(
      id: 'voice_sara',
      name: 'Sara',
      gender: 'female',
      avatarPath: TImages.saraVoiceAvatar,
      pitch: 1.1,
      speechRate: 0.5,
      voiceType: 'Warm',
      introduction:
          'Hi, my name is Sara! I\'m here to help you communicate more effectively with a clear and supportive voice.',
    ),
    VoiceModel(
      id: 'voice_kim',
      name: 'Kim',
      gender: 'male',
      avatarPath: TImages.kimVoiceAvatar,
      pitch: 0.9,
      speechRate: 0.55,
      voiceType: 'Professional',
      introduction:
          'Hello, I\'m Kim! I\'m ready to assist you with clear and confident communication.',
    ),
    VoiceModel(
      id: 'voice_ema',
      name: 'Ema',
      gender: 'female',
      avatarPath: TImages.emaVoiceAvatar,
      pitch: 1.1,
      speechRate: 0.6,
      voiceType: 'Energetic',
      introduction:
          'Hey there, I\'m Ema! I\'m excited to help you express yourself with clarity and enthusiasm.',
    ),
    VoiceModel(
      id: 'voice_alex',
      name: 'Alex',
      gender: 'male',
      avatarPath: TImages.alexVoiceAvatar,
      pitch: 0.9,
      speechRate: 0.5,
      voiceType: 'Casual',
      introduction:
          'Hi, I\'m Alex! I\'m here to support your communication journey with a friendly and approachable voice.',
    ),
  ];

  static VoiceModel get defaultVoice => availableVoices[0];
}
