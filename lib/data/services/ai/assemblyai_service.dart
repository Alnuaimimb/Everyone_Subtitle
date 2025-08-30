import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:everyone_subtitle/utils/constants/api.dart';

class AssemblyAIService {
  // Read the API key from .env or --dart-define
  static String get _apiKey => Env.assemblyAIKey;

  static const String _baseUrl = 'https://api.assemblyai.com/v2';

  static final AudioRecorder _audioRecorder = AudioRecorder();
  static Timer? _pollingTimer;
  static String? _currentTranscriptionId;
  static String? _currentAudioPath;
  static Function(String)? _onTranscriptCb;
  static Function(String)? _onErrorCb;
  static bool _isRecording = false;
  static bool _isStopping = false;

  // Initialize audio recorder
  static Future<bool> initializeRecorder() async {
    try {
      // Request microphone permission explicitly
      final status = await Permission.microphone.request();
      final hasPermission =
          status.isGranted || await _audioRecorder.hasPermission();
      if (!hasPermission) {
        return false;
      }
      return true;
    } catch (e) {
      print('Error initializing recorder: $e');
      return false;
    }
  }

  // Start recording audio
  static Future<void> startRecording({
    required Function(String) onTranscriptUpdate,
    required Function(String) onError,
  }) async {
    try {
      _onTranscriptCb = onTranscriptUpdate;
      _onErrorCb = onError;
      // Get temporary directory for audio file
      final tempDir = await getTemporaryDirectory();
      final audioPath = '${tempDir.path}/temp_audio.wav';
      _currentAudioPath = audioPath;

      if (_isRecording) return; // Prevent double start
      // Start recording
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 16000,
          sampleRate: 16000,
        ),
        path: audioPath,
      );

      // Show immediate feedback
      onTranscriptUpdate('Listening... Speak now...');
      _isRecording = true;

      // We now transcribe only when the user stops the recording for reliability.
    } catch (e) {
      onError('Failed to start recording: $e');
    }
  }

  // Stop recording
  static Future<void> stopRecording() async {
    try {
      if (_isStopping) return;
      _isStopping = true;
      print('[AssemblyAI] Stopping recording...');
      if (_isRecording) {
        await _audioRecorder.stop();
      }
      _stopPeriodicTranscription();
      if (_currentAudioPath != null &&
          _onTranscriptCb != null &&
          _onErrorCb != null) {
        // Early check: ensure we captured enough audio
        final f = File(_currentAudioPath!);
        if (!(await f.exists()) || (await f.length()) < 8192) {
          print('[AssemblyAI] Audio file too small or missing');
          _onErrorCb!.call('No audio captured. Try speaking a bit longer.');
          return;
        }
        print('[AssemblyAI] Audio file size: ${await f.length()} bytes');
        // Finalize: upload once and poll until completed (short capped loop)
        await _transcribeAudioFile(
          audioPath: _currentAudioPath!,
          onTranscriptUpdate: _onTranscriptCb!,
          onError: _onErrorCb!,
        );
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
    _isRecording = false;
    _isStopping = false;
  }

  // Start periodic transcription
  static void _startPeriodicTranscription({
    required String audioPath,
    required Function(String) onTranscriptUpdate,
    required Function(String) onError,
  }) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final file = File(audioPath);
        if (await file.exists() && await file.length() > 1000) {
          // Only process if file has meaningful content
          await _transcribeAudioFile(
            audioPath: audioPath,
            onTranscriptUpdate: onTranscriptUpdate,
            onError: onError,
          );
        }
      } catch (e) {
        print('Transcription error: $e');
        // Don't call onError here to avoid stopping the recording
      }
    });
  }

  // Stop periodic transcription
  static void _stopPeriodicTranscription() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentTranscriptionId = null;
  }

  // Transcribe audio file
  static Future<void> _transcribeAudioFile({
    required String audioPath,
    required Function(String) onTranscriptUpdate,
    required Function(String) onError,
  }) async {
    try {
      // Upload audio file (AssemblyAI expects binary POST to /upload)
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) return;
      final audioBytes = await audioFile.readAsBytes();

      final uploadResp = await http
          .post(
            Uri.parse('$_baseUrl/upload'),
            headers: {
              'Authorization': _apiKey,
              'Content-Type': 'application/octet-stream',
            },
            body: audioBytes,
          )
          .timeout(const Duration(seconds: 10));

      if (uploadResp.statusCode != 200) {
        throw Exception('Failed to upload audio: ${uploadResp.statusCode}');
      }

      final uploadData = jsonDecode(uploadResp.body);
      final audioUrl = uploadData['upload_url'];

      // Submit transcription request
      final transcriptionResponse = await http
          .post(
            Uri.parse('$_baseUrl/transcript'),
            headers: {
              'Authorization': _apiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'audio_url': audioUrl,
              // Optional features could be enabled here
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (transcriptionResponse.statusCode != 200) {
        throw Exception(
            'Failed to submit transcription: ${transcriptionResponse.statusCode}');
      }

      final transcriptionData = jsonDecode(transcriptionResponse.body);
      _currentTranscriptionId = transcriptionData['id'];

      // Poll for results (limited attempts to avoid long blocks)
      bool completed = false;
      for (int i = 0; i < 30; i++) {
        final ok = await _pollTranscriptionResult(
          transcriptionId: _currentTranscriptionId!,
          onTranscriptUpdate: onTranscriptUpdate,
          onError: onError,
        );
        if (ok) {
          completed = true;
          break;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
      if (!completed) {
        onError('Transcription timed out. Please try again.');
      }
    } catch (e) {
      onError('Transcription failed: $e');
    }
  }

  // Poll transcription result
  static Future<bool> _pollTranscriptionResult({
    required String transcriptionId,
    required Function(String) onTranscriptUpdate,
    required Function(String) onError,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transcript/$transcriptionId'),
        headers: {
          'Authorization': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        print('[AssemblyAI] Polling status: $status');

        if (status == 'completed') {
          final text = data['text'] ?? '';
          print('[AssemblyAI] Transcription completed: "$text"');
          if (text.isNotEmpty) {
            onTranscriptUpdate(text);
          }
          return true;
        } else if (status == 'error') {
          print('[AssemblyAI] Transcription error: ${data['error']}');
          onError('Transcription error: ${data['error']}');
          return true;
        }
      } else {
        throw Exception('Failed to get transcription: ${response.statusCode}');
      }
    } catch (e) {
      print('[AssemblyAI] Polling error: $e');
      onError('Polling error: $e');
    }
    return false;
  }

  // Check if recording
  static Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  // Dispose resources
  static void dispose() {
    _pollingTimer?.cancel();
    _audioRecorder.dispose();
    _isRecording = false;
    _isStopping = false;
  }
}
