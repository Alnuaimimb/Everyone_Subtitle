import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/voice/models/voice_model.dart';
import 'package:everyone_subtitle/utils/constants/voice_constants.dart';
import 'package:everyone_subtitle/data/services/ai/openai_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class VoiceController extends GetxController {
  static VoiceController get instance => Get.find();

  final Rx<VoiceModel?> selectedVoice = Rx<VoiceModel?>(null);
  final List<VoiceModel> availableVoices = VoiceConstants.availableVoices;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isPreviewing = false.obs;
  bool _apAvailable = true;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedVoice();
    _initializeAudioPlayers();
    _checkPluginRegistration();
  }

  void _checkPluginRegistration() {
    print('[VoiceController] Checking plugin registration...');
    print(
        '[VoiceController] Platform: ${GetPlatform.isAndroid ? "Android" : "iOS"}');
    print('[VoiceController] audioplayers version: 5.2.1');

    // Check if we're running on a supported platform
    if (GetPlatform.isAndroid) {
      print('[VoiceController] Android platform detected');
    } else if (GetPlatform.isIOS) {
      print('[VoiceController] iOS platform detected');
    } else {
      print(
          '[VoiceController] Web/Desktop platform detected - audioplayers may not work');
    }

    // Test if audioplayers classes are available
    try {
      final testPlayer = AudioPlayer();
      print('[VoiceController] AudioPlayer class is available');

      // Test if we can create a simple source
      final testBytes = Uint8List.fromList([0, 0, 0, 0]);
      final testSource = BytesSource(testBytes);
      print('[VoiceController] BytesSource class is available');
    } catch (e) {
      print('[VoiceController] Plugin registration test failed: $e');
      print(
          '[VoiceController] This indicates audioplayers plugin is not properly registered');
    }
  }

  void _initializeAudioPlayers() async {
    try {
      print('[VoiceController] Initializing audio players...');

      // Test audioplayers plugin with detailed error reporting
      await _testAudioPlayersPlugin();

      // Test basic audioplayers functionality
      await _testAudioPlayersBasicFunctionality();
    } catch (e) {
      print('[VoiceController] Error initializing audio players: $e');
      _apAvailable = false;
    }
  }

  Future<void> _testAudioPlayersPlugin() async {
    try {
      print('[VoiceController] Testing audioplayers plugin initialization...');

      // Test if we can create an AudioPlayer instance
      final testPlayer = AudioPlayer();
      print('[VoiceController] AudioPlayer instance created successfully');

      // Test basic operations
      await testPlayer.setVolume(1.0);
      print('[VoiceController] AudioPlayer volume set successfully');

      // Test if we can stop (should not throw)
      await testPlayer.stop();
      print('[VoiceController] AudioPlayer stop operation successful');

      // Dispose test player
      await testPlayer.dispose();
      print('[VoiceController] AudioPlayer disposed successfully');

      print('[VoiceController] audioplayers plugin test: PASSED');
      _apAvailable = true;
    } catch (e) {
      print('[VoiceController] audioplayers plugin test: FAILED');
      print('[VoiceController] Error details: $e');
      print('[VoiceController] Error type: ${e.runtimeType}');
      _apAvailable = false;
    }
  }

  Future<void> _testAudioPlayersBasicFunctionality() async {
    try {
      print('[VoiceController] Testing audioplayers basic functionality...');

      // Test if we can create a simple audio source
      final testBytes = Uint8List.fromList([0, 0, 0, 0]);
      final testSource = BytesSource(testBytes);
      print('[VoiceController] BytesSource created successfully');

      print('[VoiceController] audioplayers basic functionality test: PASSED');
    } catch (e) {
      print('[VoiceController] audioplayers basic functionality test: FAILED');
      print('[VoiceController] Error details: $e');
      print('[VoiceController] Error type: ${e.runtimeType}');
      _apAvailable = false;
    }
  }

  Future<void> _playAudioFromFile(Uint8List audioData) async {
    try {
      print('[VoiceController] Starting audio playback...');
      print('[VoiceController] Audio data size: ${audioData.length} bytes');

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/voice_preview.mp3');
      print('[VoiceController] Temporary file path: ${audioFile.path}');

      // Write audio data to file
      await audioFile.writeAsBytes(audioData);
      print('[VoiceController] Audio data written to file successfully');

      // Verify file exists and has content
      if (await audioFile.exists()) {
        final fileSize = await audioFile.length();
        print('[VoiceController] File exists with size: $fileSize bytes');
      } else {
        throw Exception('Audio file was not created');
      }

      // Try audioplayers if available
      if (_apAvailable) {
        print('[VoiceController] Attempting audioplayers playback...');
        try {
          // Stop any current playback
          await _audioPlayer.stop();
          print('[VoiceController] Stopped current playback');

          // Create file source
          final fileSource = DeviceFileSource(audioFile.path);
          print('[VoiceController] Created DeviceFileSource');

          // Play the audio
          await _audioPlayer.play(fileSource);
          print('[VoiceController] audioplayers playback started successfully');
          return;
        } catch (e) {
          print('[VoiceController] audioplayers playback failed');
          print('[VoiceController] Error details: $e');
          print('[VoiceController] Error type: ${e.runtimeType}');
          _apAvailable = false;

          // Try alternative method: BytesSource
          print('[VoiceController] Trying BytesSource as fallback...');
          try {
            await _audioPlayer.stop();
            await _audioPlayer.play(BytesSource(audioData));
            print('[VoiceController] BytesSource playback successful');
            return;
          } catch (e2) {
            print('[VoiceController] BytesSource also failed: $e2');
            throw Exception(
                'All audioplayers methods failed: $e, BytesSource: $e2');
          }
        }
      } else {
        print(
            '[VoiceController] audioplayers not available, skipping playback');

        // Show user that audio was generated but playback failed
        Get.snackbar(
          'Voice Generated Successfully',
          'Audio was generated but playback is not available. Please check your device audio settings.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        // Don't throw exception, just log the issue
        print(
            '[VoiceController] Audio generation successful but playback failed due to plugin issues');
        return; // Exit gracefully
      }
    } catch (e) {
      print('[VoiceController] Error in _playAudioFromFile: $e');
      print('[VoiceController] Error type: ${e.runtimeType}');
      throw e;
    }
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

  Future<void> generateDynamicVoice(VoiceModel voice) async {
    try {
      final characteristics = await OpenAIService.generateVoiceCharacteristics(
        voiceName: voice.name,
        gender: voice.gender,
      );

      // Update the voice with AI-generated characteristics
      final updatedVoice = VoiceModel(
        id: voice.id,
        name: voice.name,
        gender: voice.gender,
        avatarPath: voice.avatarPath,
        pitch: characteristics['pitch'],
        speechRate: characteristics['speechRate'],
        voiceType: voice.gender, // Use gender as voice type
        introduction: characteristics['introduction'],
      );

      selectedVoice.value = updatedVoice;
    } catch (e) {
      print('Error generating dynamic voice: $e');
      // Fall back to original voice
      selectedVoice.value = voice;
    }
  }

  Future<void> previewVoice(VoiceModel voice) async {
    if (isPreviewing.value) return;

    isPreviewing.value = true;
    selectVoice(voice);

    try {
      print('[VoiceController] Starting voice preview for ${voice.name}...');
      print('[VoiceController] Voice details: ${voice.name} (${voice.gender})');

      // Generate dynamic voice characteristics using OpenAI
      await generateDynamicVoice(voice);

      print(
          '[VoiceController] Attempting OpenAI TTS for ${selectedVoice.value!.name}...');

      // Stop any current audio first
      try {
        await _audioPlayer.stop();
        print('[VoiceController] Stopped any current audio playback');
      } catch (e) {
        print('[VoiceController] Error stopping current audio: $e');
      }

      // Generate speech using OpenAI TTS
      final firstName = await _loadFirstName();
      final preview = 'Hey, I am $firstName';
      print('[VoiceController] Preview text: "$preview"');

      print('[VoiceController] Calling OpenAI TTS...');
      final audioData = await OpenAIService.generateSpeech(
        text: preview,
        voiceName: selectedVoice.value!.name,
        gender: selectedVoice.value!.gender,
      );

      if (audioData != null && audioData.isNotEmpty) {
        print(
            '[VoiceController] OpenAI TTS generated ${audioData.length} bytes of audio data');

        // Try to play the generated audio
        print('[VoiceController] Attempting to play audio...');
        await _playAudioFromFile(audioData);
        print(
            '[VoiceController] Voice preview successful: ${selectedVoice.value!.name}');
        return; // Success, exit early
      } else {
        print('[VoiceController] OpenAI TTS returned null or empty audio data');
        throw Exception('No audio data received from OpenAI');
      }
    } catch (e) {
      print('[VoiceController] Voice preview failed with error: $e');
      print('[VoiceController] Error type: ${e.runtimeType}');
      print('[VoiceController] Error stack trace: ${StackTrace.current}');

      // Check if this is an audioplayers plugin issue
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('audioplayers') ||
          e.toString().contains('Audio playback failed')) {
        // Show user that audio was generated but playback failed
        Get.snackbar(
          'Voice Generated Successfully! 🎉',
          'OpenAI voice was created but audio playback is not working. This is a device compatibility issue.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        print(
            '[VoiceController] Audio generation successful but playback failed due to plugin issues');
        print(
            '[VoiceController] This is a known issue with audioplayers plugin on some devices');
      } else {
        // Show user that OpenAI TTS failed
        Get.snackbar(
          'Voice Preview Failed',
          'Unable to generate voice preview. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }

      // Fall back to original voice
      selectVoice(voice);
    } finally {
      isPreviewing.value = false;
      print('[VoiceController] Voice preview completed');
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
