import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';
import 'package:everyone_subtitle/data/services/ai/assemblyai_service.dart';
import 'package:everyone_subtitle/data/services/ai/openai_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/data/services/ai/profile_improvement_service.dart';

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
  final RxString selectedTone = ''.obs; // Agree/Disagree/Neutral/Question
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxString responseA = ''.obs; // candidate for A (Agree)
  final RxString responseB = ''.obs; // candidate for B (Disagree)
  final RxString responseAText = ''.obs; // full text for option A
  final RxString responseBText = ''.obs; // full text for option B
  final RxInt _indexA = (-1).obs; // rotation index for A
  final RxInt _indexB = (-1).obs; // rotation index for B

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

  // Test API connection
  Future<void> testAPI() async {
    print('Testing OpenAI API connection...');
    final isWorking = await OpenAIService.testAPIConnection();
    print('OpenAI API working: $isWorking');
  }

  // Save response to history for profile improvement
  void saveResponseToHistory() {
    if (responseText.value.isEmpty || userProfile.value == null) return;

    // Save to profile improvement service
    ProfileImprovementService.saveResponseChoice(
      transcript: transcript.value,
      selectedResponse: responseText.value,
      selectedOption: selectedTone.value,
      currentProfile: userProfile.value!,
    );

    // Also save to local history
    final historyEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'transcript': transcript.value,
      'selectedResponse': responseText.value,
      'selectedOption': selectedTone.value,
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

      // Only generate responses if we have actual transcript content
      if (transcript.value.isNotEmpty && transcript.value != 'Processing…') {
        await generateResponses();
      }
    } else {
      // Start recording
      final hasPermission = await AssemblyAIService.initializeRecorder();
      if (hasPermission) {
        // Clear previous response options when starting new recording
        responseA.value = '';
        responseB.value = '';
        responseAText.value = '';
        responseBText.value = '';
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
    // Clear response options when clearing transcript
    responseA.value = '';
    responseB.value = '';
    responseAText.value = '';
    responseBText.value = '';
    responseText.value = '';
  }

  /// Generate responses using OpenAI based on transcript and personality
  Future<void> generateResponses() async {
    print('generateResponses called with transcript: "${transcript.value}"');

    if (transcript.value.isEmpty || transcript.value == 'Processing…') {
      responseText.value = 'No input provided.';
      return;
    }

    try {
      // Generate response options using OpenAI
      final options = await OpenAIService.generateResponseOptions(
        transcript: transcript.value,
        userProfile: userProfile.value,
      );

      print('OpenAI returned options: $options');

      // Update response option titles
      responseA.value = options['optionA'] ?? 'Agree';
      responseB.value = options['optionB'] ?? 'Disagree';

      // Update full texts
      responseAText.value =
          options['responseA'] ?? 'I understand what you\'re saying.';
      responseBText.value =
          options['responseB'] ?? 'Could you clarify a bit more?';

      // Default to first option
      responseText.value = responseAText.value;
      selectedTone.value = 'A';

      print('Updated responses - A: ${responseA.value}, B: ${responseB.value}');
    } catch (e) {
      print('Error generating responses: $e');
      // Fallback to default responses
      responseA.value = 'Agree';
      responseB.value = 'Disagree';
      responseAText.value = 'I understand what you\'re saying.';
      responseBText.value =
          'I see it differently; could we consider alternatives?';
      responseText.value = responseAText.value;
    }
  }

  // Legacy responses list kept for backward compatibility (not used by new UI)

  void selectResponse(int index) {
    selectedResponseIndex.value = index;
  }

  String? get selectedResponse => selectedResponseIndex.value >= 0 &&
          selectedResponseIndex.value < responses.length
      ? responses[selectedResponseIndex.value]
      : null;

  // New tone-based mock responses for Page 2
  static const _toneKeys = ['Agree', 'Disagree', 'Neutral', 'Question'];
  final Map<String, List<String>> _toneResponses = const {
    'Agree': [
      'I agree with that and support moving forward.',
      'Absolutely, that aligns with my thinking.',
      'Yes, I’m on board with this approach.',
    ],
    'Disagree': [
      'I see it differently; here’s my concern…',
      'I’m not sure this is the right direction.',
      'I respectfully disagree; may we consider alternatives?',
    ],
    'Neutral': [
      'I can work with either option; let’s weigh pros and cons.',
      'I’m neutral and open to what the group decides.',
      'No strong preference; happy to support the team choice.',
    ],
    'Question': [
      'Could you clarify the expected outcome?',
      'What are the constraints and timeline?',
      'Can you share more context behind this decision?',
    ],
  };

  void generateForTone(String tone) {
    selectedTone.value = tone;
    final list = _toneResponses[tone] ?? _toneResponses['Neutral']!;

    // If user profile exists, try to personalize the response
    if (userProfile.value != null) {
      final profile = userProfile.value!;
      final baseResponse = list.first;

      // Simple personalization based on speaking style
      String personalizedResponse = baseResponse;

      if (profile.speakingStyle.toLowerCase().contains('formal')) {
        personalizedResponse = baseResponse
            .replaceAll("I'm", "I am")
            .replaceAll("don't", "do not");
      } else if (profile.speakingStyle.toLowerCase().contains('casual')) {
        personalizedResponse = baseResponse
            .replaceAll("I am", "I'm")
            .replaceAll("do not", "don't");
      }

      // Add personality traits if they suggest empathy
      if (profile.traits.any((trait) =>
          trait.toLowerCase().contains('empathetic') ||
          trait.toLowerCase().contains('caring'))) {
        if (!personalizedResponse.contains('understand') &&
            !personalizedResponse.contains('feel')) {
          personalizedResponse =
              "I understand how you feel. $personalizedResponse";
        }
      }

      responseText.value = personalizedResponse;
    } else {
      responseText.value = list.first;
    }
  }

  void regenerateForCurrentTone() {
    final tone = selectedTone.value.isEmpty ? 'Neutral' : selectedTone.value;
    final list = _toneResponses[tone] ?? _toneResponses['Neutral']!;
    // Rotate choices for a simple variation effect.
    if (list.isNotEmpty) {
      final current = responseText.value;
      final idx = (list.indexOf(current) + 1) % list.length;
      responseText.value = list[idx];
    }
  }

  /// Refresh both A and B candidates to new variants.
  void refreshAB() {
    // Agree track
    final agreeList = _toneResponses['Agree']!;
    _indexA.value = (_indexA.value + 1) % agreeList.length;
    responseA.value = agreeList[_indexA.value];

    // Disagree track
    final disagreeList = _toneResponses['Disagree']!;
    _indexB.value = (_indexB.value + 1) % disagreeList.length;
    responseB.value = disagreeList[_indexB.value];
  }

  void applyOptionA() {
    if (responseA.value.isEmpty) refreshAB();
    selectedTone.value = 'Agree';
    responseText.value =
        responseAText.value.isNotEmpty ? responseAText.value : responseA.value;
  }

  void applyOptionB() {
    if (responseB.value.isEmpty) refreshAB();
    selectedTone.value = 'Disagree';
    responseText.value =
        responseBText.value.isNotEmpty ? responseBText.value : responseB.value;
  }
}
