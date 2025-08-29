import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';
import 'package:everyone_subtitle/data/services/ai/assemblyai_service.dart';
import 'package:everyone_subtitle/data/services/ai/openai_service.dart'
    as openai;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:everyone_subtitle/data/services/profile/profile_improvement_service.dart';

/// Controls the shared state between the conversation pages.
/// Holds the transcript (speech-to-text), recording state, and generated responses.
class ConversationController extends GetxController {
  static ConversationController get instance => Get.find();

  final RxString transcript = ''.obs;
  final RxBool isRecording = false.obs;
  final RxList<String> responses =
      <String>[].obs; // legacy mock list (unused in new UI)
  final RxInt selectedResponseIndex =
      (-1).obs; // legacy selection (unused in new UI)
  final RxString responseText = ''.obs; // current generated/selected response
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);

  // TTS functionality
  final FlutterTts _flutterTts = FlutterTts();
  final RxBool isSpeaking = false.obs;

  // Response history for profile improvement
  final RxList<Map<String, dynamic>> responseHistory =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _initializeTTS();
  }

  void _loadUserProfile() {
    try {
      final storage = GetStorage();
      final profileData = storage.read('userProfile');
      if (profileData != null) {
        userProfile.value = UserProfile.fromJson(profileData);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Initialize TTS
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      isSpeaking.value = true;
    });

    _flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    _flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;
      print('TTS Error: $msg');
    });
  }

  // Speak the current response
  Future<void> speakResponse() async {
    if (responseText.value.isEmpty) return;

    if (isSpeaking.value) {
      await _flutterTts.stop();
    } else {
      await _flutterTts.speak(responseText.value);
    }
  }

  // Test API connection (optional)
  Future<void> testAPI() async {}

  // Save response to history for profile improvement
  void saveResponseToHistory() {
    if (responseText.value.isEmpty || userProfile.value == null) return;

    // Save to profile improvement service
    ProfileImprovementService.saveResponseChoice(
      transcript: transcript.value,
      selectedResponse: responseText.value,
    );

    // Also save to local history
    final historyEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'transcript': transcript.value,
      'selectedResponse': responseText.value,
      'selectedOption': 'Single',
      'userProfile': userProfile.value?.toJson(),
    };

    responseHistory.add(historyEntry);

    // Save to local storage
    final storage = GetStorage();
    final history = storage.read('responseHistory') ?? [];
    history.add(historyEntry);
    storage.write('responseHistory', history);

    print('Response saved to history: ${responseText.value}');
  }

  @override
  void onClose() {
    AssemblyAIService.dispose();
    _flutterTts.stop();
    super.onClose();
  }

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      // Stop recording and process
      transcript.value = 'Processing…';
      await AssemblyAIService.stopRecording();
      isRecording.value = false;

      // Wait a bit for transcript to be fully processed
      await Future.delayed(const Duration(seconds: 2));

      // Do not auto-generate; user will press Generate on next screen
    } else {
      // Start recording
      final hasPermission = await AssemblyAIService.initializeRecorder();
      if (hasPermission) {
        // Clear previous response when starting new recording
        responseText.value = '';

        // Indicate listening
        transcript.value = 'Listening… Speak now';

        await AssemblyAIService.startRecording(
          onTranscriptUpdate: (text) {
            print('Transcript update: $text'); // Debug log
            transcript.value = text;
          },
          onError: (error) {
            // Surface error to the UI so user understands what's happening
            transcript.value = error;
          },
        );
        isRecording.value = true;
      } else {
        print('No microphone permission');
      }
    }
  }

  void updateTranscript(String text) {
    transcript.value = text;
  }

  void clearTranscript() {
    transcript.value = '';
    isRecording.value = false;
    AssemblyAIService.stopRecording();
    // Clear response when clearing transcript
    responseText.value = '';
  }

  /// Generate single response using OpenAI based on transcript and personality
  Future<void> generateResponses() async {
    print('generateResponses called with transcript: "${transcript.value}"');

    if (transcript.value.isEmpty || transcript.value == 'Processing…') {
      responseText.value = 'No input provided.';
      return;
    }

    try {
      // Generate single response using OpenAI
      final response = await openai.OpenAIService.generateSingleResponse(
        transcript: transcript.value,
        userProfile: userProfile.value,
      );

      print('OpenAI returned response: $response');
      responseText.value = response;
    } catch (e) {
      print('Error generating response: $e');
      // Fallback to default response
      responseText.value = 'I understand what you\'re saying.';
    }
  }
}
