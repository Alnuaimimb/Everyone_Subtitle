import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/voice/models/voice_model.dart';
import 'package:everyone_subtitle/utils/constants/voice_constants.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceController extends GetxController {
  static VoiceController get instance => Get.find();

  final Rx<VoiceModel?> selectedVoice = Rx<VoiceModel?>(null);
  final List<VoiceModel> availableVoices = VoiceConstants.availableVoices;
  final FlutterTts _tts = FlutterTts();
  final RxBool isPreviewing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedVoice();
  }

  void _loadSelectedVoice() {
    try {
      final storage = GetStorage();
      final voiceData = storage.read('selectedVoice');
      if (voiceData != null) {
        selectedVoice.value = VoiceModel.fromJson(voiceData);
      } else {
        // Set default voice if none selected
        selectedVoice.value = VoiceConstants.defaultVoice;
      }
    } catch (e) {
      print('Error loading selected voice: $e');
      selectedVoice.value = VoiceConstants.defaultVoice;
    }
  }

  void selectVoice(VoiceModel voice) {
    selectedVoice.value = voice;
  }

  Future<void> previewVoice(VoiceModel voice) async {
    selectVoice(voice);
    isPreviewing.value = true;

    try {
      // Stop any current speech first
      await _tts.stop();

      // Configure TTS settings
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(voice.speechRate);
      await _tts.setPitch(voice.pitch);
      await _tts.setVolume(1.0);

      // Speak the voice's introduction
      await _tts.speak(voice.introduction);

      print('Voice preview: ${voice.name} - ${voice.introduction}');
    } catch (e) {
      print('Voice preview error: $e');
      // Show a snackbar or toast to inform the user
      Get.snackbar(
        'Voice Preview',
        'Unable to preview voice. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isPreviewing.value = false;
    }
  }

  Future<String> _loadFirstName() async {
    try {
      final u = FirebaseAuth.instance.currentUser;
      if (u == null) return 'your assistant';
      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(u.uid).get();
      final data = doc.data();
      final first = (data?['FirstName'] ?? '').toString();
      if (first.isNotEmpty) return first;
      // fallback to saved value if any
      final storage = GetStorage();
      final cached = storage.read('FirstName');
      if (cached is String && cached.isNotEmpty) return cached;
      return 'your assistant';
    } catch (_) {
      return 'your assistant';
    }
  }

  void saveSelectedVoice() {
    try {
      final storage = GetStorage();
      if (selectedVoice.value != null) {
        storage.write('selectedVoice', selectedVoice.value!.toJson());
        print('Voice saved: ${selectedVoice.value!.name}');
      }
    } catch (e) {
      print('Error saving selected voice: $e');
    }
  }

  VoiceModel get currentVoice =>
      selectedVoice.value ?? VoiceConstants.defaultVoice;
}
