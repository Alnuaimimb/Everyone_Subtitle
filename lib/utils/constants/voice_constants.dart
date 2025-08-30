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
      voiceType: 'warm',
      introduction:
          'Hi, my name is Sara! I have a warm and friendly voice that makes conversations feel comfortable and natural.',
    ),
    VoiceModel(
      id: 'voice_kim',
      name: 'Kim',
      gender: 'female',
      avatarPath: TImages.kimVoiceAvatar,
      pitch: 1.0,
      speechRate: 0.6,
      voiceType: 'professional',
      introduction:
          'Hello, I\'m Kim! I speak with a clear, professional tone that\'s perfect for business and formal conversations.',
    ),
    VoiceModel(
      id: 'voice_ema',
      name: 'Ema',
      gender: 'female',
      avatarPath: TImages.emaVoiceAvatar,
      pitch: 1.2,
      speechRate: 0.7,
      voiceType: 'energetic',
      introduction:
          'Hey there, I\'m Ema! I have a cheerful and energetic voice that brings positivity to every conversation.',
    ),
    VoiceModel(
      id: 'voice_alex',
      name: 'Alex',
      gender: 'male',
      avatarPath: TImages.alexVoiceAvatar,
      pitch: 0.8,
      speechRate: 0.4,
      voiceType: 'casual',
      introduction:
          'Hi, I\'m Alex! I speak in a relaxed, casual manner that makes chatting feel easy and natural.',
    ),
  ];

  static VoiceModel get defaultVoice => availableVoices[0];
}
