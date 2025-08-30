import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';
import 'package:everyone_subtitle/Features/voice/models/voice_model.dart';
import 'package:everyone_subtitle/data/services/ai/assemblyai_service.dart';
import 'package:everyone_subtitle/data/services/ai/openai_service.dart'
    as openai;
import 'package:everyone_subtitle/data/services/profile/profile_improvement_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

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
  AudioPlayer? _audioPlayer;
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

  void _loadUserProfile() async {
    try {
      final storage = GetStorage();
      final profileData = storage.read('userProfile');

      if (profileData != null) {
        userProfile.value = UserProfile.fromJson(profileData);
      } else {
        // If not in local storage, try to load from Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();
            if (doc.exists) {
              final data = doc.data();
              if (data?['profile'] != null) {
                userProfile.value = UserProfile.fromJson(data!['profile']);
                // Save to local storage for future use
                await storage.write('userProfile', data['profile']);
              }
            }
          } catch (e) {
            print('Error loading profile from Firestore: $e');
          }
        }
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

  // Initialize TTS (OpenAI-based)
  Future<void> _initializeTTS() async {
    // OpenAI TTS is initialized on-demand
    print('TTS initialized for OpenAI voice generation');
  }

  // Speak the current response using OpenAI TTS
  Future<void> speakResponse() async {
    if (responseText.value.isEmpty) return;

    if (isSpeaking.value) {
      isSpeaking.value = false;
      return;
    }

    try {
      isSpeaking.value = true;
      print('[ConversationController] Starting speech for response...');

      // Get selected voice
      final storage = GetStorage();
      final voiceData = storage.read('selectedVoice');
      String voiceName = 'Sara';
      String gender = 'female';

      if (voiceData != null) {
        try {
          final voice = VoiceModel.fromJson(voiceData);
          voiceName = voice.name;
          gender = voice.gender;
          print('[ConversationController] Using voice: $voiceName ($gender)');
        } catch (e) {
          print('[ConversationController] Error loading voice settings: $e');
        }
      } else {
        print(
            '[ConversationController] No voice selected, using default: $voiceName');
      }

      // Generate speech using OpenAI TTS
      print('[ConversationController] Generating speech with OpenAI TTS...');
      final audioData = await openai.OpenAIService.generateSpeech(
        text: responseText.value,
        voiceName: voiceName,
        gender: gender,
      );

      if (audioData != null && audioData.isNotEmpty) {
        print(
            '[ConversationController] OpenAI TTS generated ${audioData.length} bytes');

        // Play the generated audio
        await _playResponseAudio(audioData);
      } else {
        print(
            '[ConversationController] Failed to generate speech with OpenAI TTS');
        Get.snackbar(
          'Speech Generation Failed',
          'Unable to generate speech for the response.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('[ConversationController] Error in speakResponse: $e');
      print('[ConversationController] Error type: ${e.runtimeType}');

      Get.snackbar(
        'Speech Error',
        'Unable to speak the response. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isSpeaking.value = false;
    }
  }

  // Get or create AudioPlayer instance
  AudioPlayer _getOrCreateAudioPlayer() {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
      print('[ConversationController] Created new AudioPlayer instance');
    }
    return _audioPlayer!;
  }

  // Play the response audio using audioplayers
  Future<void> _playResponseAudio(Uint8List audioData) async {
    try {
      print('[ConversationController] Starting audio playback...');

      // Get or create AudioPlayer
      final audioPlayer = _getOrCreateAudioPlayer();

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/response_audio.mp3');
      print('[ConversationController] Temporary file path: ${audioFile.path}');

      // Write audio data to file
      await audioFile.writeAsBytes(audioData);
      print('[ConversationController] Audio data written to file successfully');

      // Verify file exists and has content
      if (await audioFile.exists()) {
        final fileSize = await audioFile.length();
        print(
            '[ConversationController] File exists with size: $fileSize bytes');
      } else {
        throw Exception('Audio file was not created');
      }

      // Try to play using audioplayers
      try {
        // Stop any current playback
        await audioPlayer.stop();
        print('[ConversationController] Stopped current playback');

        // Create file source and play
        final fileSource = DeviceFileSource(audioFile.path);
        await audioPlayer.play(fileSource);
        print('[ConversationController] Audio playback started successfully');
      } catch (e) {
        print('[ConversationController] audioplayers playback failed: $e');

        // Try alternative method: BytesSource
        try {
          await audioPlayer.stop();
          await audioPlayer.play(BytesSource(audioData));
          print('[ConversationController] BytesSource playback successful');
        } catch (e2) {
          print('[ConversationController] BytesSource also failed: $e2');

          // Show user that audio was generated but playback failed
          Get.snackbar(
            'Response Generated Successfully! 🎉',
            'Audio was generated but playback is not available. Please check your device audio settings.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      print('[ConversationController] Error in _playResponseAudio: $e');
      print('[ConversationController] Error type: ${e.runtimeType}');

      // Show user that audio was generated but playback failed
      Get.snackbar(
        'Response Generated Successfully! 🎉',
        'Audio was generated but playback is not available. Please check your device audio settings.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
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
    _audioPlayer?.dispose();
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
