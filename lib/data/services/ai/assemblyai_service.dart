import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:everyone_subtitle/utils/constants/api.dart';

/// Live (streaming) STT using AssemblyAI Realtime,
/// with safe fallback to file-based transcription.
/// Emits partial transcripts continuously and final transcripts as they arrive.
class AssemblyAIService {
  // ======== Config / Keys ========
  static String? get _apiKey => Env.assemblyAIKeyOrNull;
  static const String _baseUrl = 'https://api.assemblyai.com/v2';
  static const int _sampleRate = 16000;

  // ======== State ========
  static final AudioRecorder _rec = AudioRecorder();
  static WebSocketChannel? _ws;
  static StreamSubscription? _wsSub;
  static StreamSubscription<Uint8List>? _micSub;
  static Timer? _pingTimer;

  static bool _isRecording = false;
  static bool _isStopping = false;
  static bool _useRealtime = true;
  static bool _cancelRequested = false;

  static String _finalText = '';
  static String _partialText = '';
  static String? _currentAudioPath;

  // callbacks
  static Function(String)? _onTranscript;
  static Function(String)? _onError;
  static void Function(String status)? _onStatus; // optional UI status

  // Micro-batching: buffer ~100ms of audio before sending (smooths network)
  static List<int> _chunkBuf = <int>[];
  static Timer? _chunkTimer;

  // ======== Public API ========

  static Future<bool> initializeRecorder() async {
    try {
      final p = await Permission.microphone.request();
      final ok = p.isGranted || await _rec.hasPermission();
      return ok;
    } catch (e) {
      return false;
    }
  }

  /// Start live transcription if possible; otherwise fall back to file mode.
  static Future<void> startRecording({
    required Function(String) onTranscriptUpdate,
    required Function(String) onError,
    void Function(String status)? onStatus,
  }) async {
    if (_isRecording) return;
    _cancelRequested = false;
    _onTranscript = onTranscriptUpdate;
    _onError = onError;
    _onStatus = onStatus;

    if (!Env.enableTranscription || _apiKey == null || _apiKey!.isEmpty) {
      _emitError('Speech-to-text unavailable: set ASSEMBLYAI_API_KEY');
      return;
    }

    _updateStatus('Initializing…');

    // try realtime first
    final ok = await _startRealtime();
    if (ok) {
      _useRealtime = true;
      _isRecording = true;
      _updateStatus('Listening…');
      return;
    }

    // fallback to file capture
    _useRealtime = false;
    _isRecording = true;
    _updateStatus('Recording (fallback)…');

    final tmp = await getTemporaryDirectory();
    _currentAudioPath = '${tmp.path}/temp_audio.wav';

    await _rec.start(
      RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: _sampleRate,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: _currentAudioPath!,
    );
  }

  /// Stop recording; in fallback mode we upload once and return the full text.
  static Future<void> stopRecording() async {
    if (_isStopping) return;
    _isStopping = true;
    _cancelRequested = false; // explicit finalize

    try {
      if (_useRealtime) {
        await _stopRealtime();
        // emit final
        if (_finalText.trim().isNotEmpty) {
          _emitTranscript(_finalText.trim());
        }
      } else {
        await _rec.stop();
        _updateStatus('Processing…');
        if (_currentAudioPath != null) {
          final file = File(_currentAudioPath!);
          if (!await file.exists() || (await file.length()) < 8192) {
            _emitError('No audio captured. Speak a bit longer then try again.');
          } else {
            await _uploadAndTranscribeFile(_currentAudioPath!);
          }
        }
      }
    } catch (e) {
      _emitError('Stop error: $e');
    } finally {
      _isRecording = false;
      _isStopping = false;
      _updateStatus('');
    }
  }

  /// Cancel current capture without finalizing; suppress further callbacks.
  static Future<void> cancelRecording() async {
    try {
      _cancelRequested = true;
      _updateStatus('');
      // stop mic/stream if any
      try {
        await _rec.stop();
      } catch (_) {}
      await _stopRealtime();
      _cancelTimers();
    } catch (e) {
      // ignore
    } finally {
      _isRecording = false;
      _isStopping = false;
    }
  }

  static Future<bool> isRecording() => _rec.isRecording();

  static void dispose() {
    _cancelTimers();
    _micSub?.cancel();
    _wsSub?.cancel();
    _ws = null;
  }

  // ======== Realtime ========

  static Future<bool> _startRealtime() async {
    try {
      // 1) ephemeral realtime token
      final t = await http
          .post(
            Uri.parse('$_baseUrl/realtime/token'),
            headers: {
              'Authorization': _apiKey!,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'expires_in': 60}),
          )
          .timeout(const Duration(seconds: 8));

      if (t.statusCode != 200) {
        _updateStatus('Realtime unavailable (token ${t.statusCode})');
        return false;
      }

      final td = jsonDecode(t.body);
      final token =
          td['token'] ?? td['realtime_token'] ?? td['access_token'] ?? '';
      if (token is! String || token.isEmpty) return false;

      // 2) connect websocket
      final uri = Uri.parse(
          'wss://api.assemblyai.com/v2/realtime/ws?sample_rate=$_sampleRate&token=$token&enable_partials=true');
      _ws = WebSocketChannel.connect(uri);

      _finalText = '';
      _partialText = '';

      _wsSub = _ws!.stream.listen((data) {
        if (data is! String) return;
        if (_cancelRequested) return;
        try {
          final msg = jsonDecode(data);
          final t = (msg['message_type'] ?? msg['type'] ?? '')
              .toString()
              .toLowerCase();
          final text = (msg['text'] ?? msg['transcript'] ?? '').toString();

          if (_cancelRequested || text.isEmpty) return;

          if (t.contains('partial')) {
            _partialText = text;
            final merged = (_finalText + ' ' + _partialText).trim();
            _emitTranscript(merged);
            _updateStatus('Transcribing…');
          } else if (t.contains('final')) {
            if (_finalText.isEmpty) {
              _finalText = text.trim();
            } else {
              _finalText = (_finalText + ' ' + text).trim();
            }
            _partialText = '';
            _emitTranscript(_finalText);
            _updateStatus('Listening…');
          } else {
            // session_begins / keepalive / unknown
          }
        } catch (_) {
          // ignore malformed frames
        }
      }, onError: (e) {
        if (!_cancelRequested) _emitError('Stream error: $e');
      }, onDone: () {
        // socket closed
      });

      // 3) start session
      _ws!.sink.add(jsonEncode({
        'message_type': 'Start',
        'sample_rate': _sampleRate,
        'encoding': 'pcm_s16le',
        'enable_partials': true,
      }));

      // 4) start mic stream and micro-batch frames (~100ms)
      final mic = await _rec.startStream(
        RecordConfig(sampleRate: _sampleRate, numChannels: 1, bitRate: 256000),
      );

      _chunkBuf = <int>[];
      _chunkTimer?.cancel();
      _chunkTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (_chunkBuf.isEmpty) return;
        final bytes = Uint8List.fromList(_chunkBuf);
        _chunkBuf.clear();
        try {
          _ws?.sink.add(jsonEncode({'audio_data': base64Encode(bytes)}));
        } catch (_) {}
      });

      _micSub = mic.listen((Uint8List data) {
        // append to micro-batch buffer
        _chunkBuf.addAll(data);
      });

      // 5) heartbeat ping (keeps connection alive on some networks)
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        try {
          _ws?.sink.add(jsonEncode({'message_type': 'ping'}));
        } catch (_) {}
      });

      return true;
    } catch (e) {
      _updateStatus('Realtime init failed');
      return false;
    }
  }

  static Future<void> _stopRealtime() async {
    try {
      _chunkTimer?.cancel();
      _chunkBuf.clear();

      await _micSub?.cancel();
      _micSub = null;

      try {
        _ws?.sink.add(jsonEncode({'message_type': 'stop'}));
      } catch (_) {}

      await _wsSub?.cancel();
      _wsSub = null;

      _pingTimer?.cancel();
      _pingTimer = null;

      try {
        await _ws?.sink.close();
      } catch (_) {}
      _ws = null;
    } catch (e) {
      _emitError('Realtime stop error: $e');
    }
  }

  // ======== Fallback: upload & poll once ========

  static Future<void> _uploadAndTranscribeFile(String wavPath) async {
    try {
      // upload
      final audioBytes = await File(wavPath).readAsBytes();
      final up = await http
          .post(
            Uri.parse('$_baseUrl/upload'),
            headers: {
              'Authorization': _apiKey!,
              'Content-Type': 'application/octet-stream',
            },
            body: audioBytes,
          )
          .timeout(const Duration(seconds: 15));
      if (up.statusCode != 200) {
        _emitError('Upload failed (${up.statusCode})');
        return;
      }
      final uploadUrl = (jsonDecode(up.body)['upload_url'] ?? '').toString();
      if (uploadUrl.isEmpty) {
        _emitError('Upload URL missing');
        return;
      }

      // request transcript
      final tr = await http
          .post(
            Uri.parse('$_baseUrl/transcript'),
            headers: {
              'Authorization': _apiKey!,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'audio_url': uploadUrl}),
          )
          .timeout(const Duration(seconds: 10));
      if (tr.statusCode != 200) {
        _emitError('Submit failed (${tr.statusCode})');
        return;
      }
      final id = (jsonDecode(tr.body)['id'] ?? '').toString();
      if (id.isEmpty) {
        _emitError('Transcript id missing');
        return;
      }

      // poll until done
      for (int i = 0; i < 30; i++) {
        final g = await http.get(
          Uri.parse('$_baseUrl/transcript/$id'),
          headers: {'Authorization': _apiKey!},
        );
        if (g.statusCode != 200) {
          _emitError('Poll failed (${g.statusCode})');
          return;
        }
        final body = jsonDecode(g.body);
        final status = (body['status'] ?? '').toString();
        if (status == 'completed') {
          final text = (body['text'] ?? '').toString();
          if (text.isNotEmpty) _emitTranscript(text);
          return;
        }
        if (status == 'error') {
          _emitError('Transcription error: ${body['error']}');
          return;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
      _emitError('Transcription timed out');
    } catch (e) {
      _emitError('Transcription failed: $e');
    }
  }

  // ======== Helpers ========

  static void _cancelTimers() {
    _chunkTimer?.cancel();
    _chunkTimer = null;
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  static void _emitTranscript(String text) {
    if (_cancelRequested) return;
    _onTranscript?.call(text);
  }

  static void _emitError(String msg) {
    if (_cancelRequested) return;
    _onError?.call(msg);
  }

  static void _updateStatus(String s) {
    _onStatus?.call(s);
  }
}
