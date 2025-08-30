import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';
import 'package:everyone_subtitle/Features/voice/models/voice_model.dart';
import 'package:everyone_subtitle/data/services/ai/assemblyai_service.dart';
import 'package:everyone_subtitle/data/services/ai/openai_service.dart'
    as openai;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:everyone_subtitle/data/services/profile/profile_improvement_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final RxMap<String, String> userIdentity = <String, String>{}.obs;
  String _transcriptPrefix = '';
  int _sessionId = 0; // increments every start/reset to ignore stale callbacks

  // TTS functionality
  final FlutterTts _flutterTts = FlutterTts();
  final RxBool isSpeaking = false.obs;

  // Response history for profile improvement
  final RxList<Map<String, dynamic>> responseHistory =
      <Map<String, dynamic>>[].obs;

  // Live transcription state
  final RxBool isLiveTranscribing = false.obs;
  final RxString liveStatus = ''.obs;
  // Disable Start/Pause during stop finalization
  final RxBool isFinalizing = false.obs;
  // Prevent double-tap on Start/Pause while a toggle is in-flight
  final RxBool isToggling = false.obs;

  // Dynamic option buttons and responses
  final RxList<String> optionButtons = <String>[].obs;
  final RxList<String> optionResponses = <String>[].obs;
  final RxBool isGeneratingOptions = false.obs;
  final RxBool isGeneratingNewResponse = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _loadUserIdentity();
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

  void _loadUserIdentity() async {
    try {
      final u = FirebaseAuth.instance.currentUser;
      if (u == null) return;
      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(u.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          userIdentity.assignAll({
            'FirstName': (data['FirstName'] ?? '').toString(),
            'LastName': (data['LastName'] ?? '').toString(),
            'Username': (data['Username'] ?? '').toString(),
            'Email': (data['Email'] ?? u.email ?? '').toString(),
            'Gender': (data['Gender'] ?? '').toString(),
          }..removeWhere((key, value) => value.isEmpty));
        }
      }
    } catch (e) {
      print('Error loading user identity: $e');
    }
  }

  // Initialize TTS
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage("en-US");

    // Load selected voice settings
    final storage = GetStorage();
    final voiceData = storage.read('selectedVoice');
    if (voiceData != null) {
      try {
        final voice = VoiceModel.fromJson(voiceData);
        await _flutterTts.setSpeechRate(voice.speechRate);
        await _flutterTts.setPitch(voice.pitch);
      } catch (e) {
        print('Error loading voice settings: $e');
        // Fallback to default settings
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
      }
    } else {
      // Default settings
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
    }

    await _flutterTts.setVolume(1.0);

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
    // Prevent multiple calls during processing/finalization or re-entrancy
    if (isToggling.value ||
        isFinalizing.value ||
        (isLiveTranscribing.value && !isRecording.value)) {
      print(
          '[ConversationController] Ignoring toggleRecording call during processing');
      return;
    }

    isToggling.value = true;
    try {
      if (isRecording.value) {
        // Stop recording and finalize; disable button until final text shown
        isFinalizing.value = true;
        liveStatus.value = 'Finalizing...';
        await AssemblyAIService.stopRecording();
        isRecording.value = false;
        isLiveTranscribing.value = false;
        liveStatus.value = '';
        isFinalizing.value = false;
        // Do not auto-generate; user will press Generate on next screen
      } else {
        // Start recording
        final int session = ++_sessionId; // new session id
        final hasPermission = await AssemblyAIService.initializeRecorder();
        if (hasPermission) {
          // Clear previous response when starting new recording
          responseText.value = '';
          optionButtons.clear();
          optionResponses.clear();

          // Prepare prefix so new speech appends after a blank line if needed
          _transcriptPrefix = transcript.value.isNotEmpty
              ? (transcript.value.endsWith('\n\n')
                  ? transcript.value
                  : '${transcript.value}\n\n')
              : '';
          isLiveTranscribing.value = true;
          liveStatus.value = 'Initializing...';

          print('[ConversationController] Starting live transcription...');

          await AssemblyAIService.startRecording(
            onTranscriptUpdate: (text) {
              if (session != _sessionId) return; // ignore stale updates
              print('[ConversationController] Live transcript update: "$text"');
              // Update transcript immediately, appending to existing text
              transcript.value = '$_transcriptPrefix$text';
              isLiveTranscribing.value = true;
              liveStatus.value = 'Transcribing...';

              // Force immediate UI update
              transcript.refresh();
            },
            onError: (error) {
              if (session != _sessionId) return; // ignore stale errors
              // Surface error to the UI so user understands what's happening
              print('[ConversationController] Transcription error: $error');
              transcript.value = error;
              isLiveTranscribing.value = false;
              liveStatus.value = 'Error: $error';
            },
            onStatus: (s) {
              if (session != _sessionId) return;
              liveStatus.value = s;
            },
          );
          isRecording.value = true;
          liveStatus.value = 'Listening...';
          print('[ConversationController] Live transcription started');

          // Update status to show we're ready for speech
          Future.delayed(const Duration(milliseconds: 500), () {
            if (isRecording.value && transcript.value.isEmpty) {
              liveStatus.value = 'Ready for speech...';
            }
          });
        } else {
          print('No microphone permission');
          liveStatus.value = 'Microphone permission denied';
        }
      }
    } finally {
      isToggling.value = false;
    }
  }

  void updateTranscript(String text) {
    transcript.value = text;
    if (text.isNotEmpty) {
      isLiveTranscribing.value = true;
      liveStatus.value = 'Transcribing...';

      // Force immediate UI update
      transcript.refresh();
    }
  }

  void clearTranscript() {
    transcript.value = '';
    isRecording.value = false;
    isLiveTranscribing.value = false;
    liveStatus.value = '';
    AssemblyAIService.cancelRecording();
    // Clear response when clearing transcript
    responseText.value = '';
    optionButtons.clear();
    optionResponses.clear();
  }

  /// Reset the entire conversation state
  void resetConversation() {
    // Invalidate any in-flight callbacks
    _sessionId++;
    // Hard cancel any recording/streams
    AssemblyAIService.cancelRecording();
    // Reset UI state
    transcript.value = '';
    _transcriptPrefix = '';
    isRecording.value = false;
    isLiveTranscribing.value = false;
    isFinalizing.value = false;
    liveStatus.value = '';
    responseText.value = '';
    responses.clear();
    selectedResponseIndex.value = -1;
    optionButtons.clear();
    optionResponses.clear();
    isGeneratingOptions.value = false;
    isGeneratingNewResponse.value = false;
    print('[ConversationController] Conversation reset');
  }

  /// Generate dynamic option buttons and responses based on transcript
  Future<void> generateOptionButtons() async {
    print(
        'generateOptionButtons called with transcript: "${transcript.value}"');

    if (transcript.value.isEmpty) {
      optionButtons.value = [];
      optionResponses.value = [];
      return;
    }

    isGeneratingOptions.value = true;

    try {
      // Generate option buttons and responses using OpenAI
      final result = await openai.OpenAIService.generateOptionButtons(
        transcript: transcript.value,
        userProfile: userProfile.value,
      );

      print('OpenAI returned options: $result');
      optionButtons.value = result['buttons'] ?? [];
      optionResponses.value = result['responses'] ?? [];
    } catch (e) {
      print('Error generating option buttons: $e');
      // Fallback to default options
      optionButtons.value = ['Agree', 'Disagree'];
      optionResponses.value = ['I agree with that.', 'I disagree with that.'];
    } finally {
      isGeneratingOptions.value = false;
    }
  }

  /// Select an option and set the corresponding response
  void selectOption(int index) {
    if (index >= 0 && index < optionResponses.length) {
      responseText.value = optionResponses[index];
    }
  }

  /// Generate single response using OpenAI based on transcript and personality
  Future<void> generateResponses() async {
    print('generateResponses called with transcript: "${transcript.value}"');

    if (transcript.value.isEmpty) {
      responseText.value = 'No input provided.';
      return;
    }

    isGeneratingNewResponse.value = true;

    try {
      // Generate single response using OpenAI
      final response = await openai.OpenAIService.generateSingleResponse(
        transcript: transcript.value,
        userProfile: userProfile.value,
        userInfo: Map<String, String>.from(userIdentity),
      );

      print('OpenAI returned response: $response');
      responseText.value = response;
    } catch (e) {
      print('Error generating response: $e');
      // Fallback to default response
      responseText.value = 'I understand what you\'re saying.';
    } finally {
      isGeneratingNewResponse.value = false;
    }
  }
}
