import 'package:get/get.dart';

/// Controls the shared state between the conversation pages.
/// Holds the transcript (speech-to-text), recording state, and generated responses.
class ConversationController extends GetxController {
  static ConversationController get instance => Get.find();

  final RxString transcript = ''.obs;
  final RxBool isRecording = false.obs;
  final RxList<String> responses = <String>[].obs; // legacy mock list (unused in new UI)
  final RxInt selectedResponseIndex = (-1).obs;   // legacy selection (unused in new UI)
  final RxString responseText = ''.obs;           // current generated/selected response
  final RxString selectedTone = ''.obs;           // Agree/Disagree/Neutral/Question

  void toggleRecording() {
    isRecording.toggle();
    // Placeholder UX: when recording starts, seed some example text.
    if (isRecording.isTrue && transcript.value.isEmpty) {
      transcript.value = 'Listening... start speaking to fill transcript.';
    }
    if (isRecording.isFalse && transcript.value.startsWith('Listening...')) {
      transcript.value = 'Hello, I would like to schedule a meeting tomorrow at 10 AM.';
    }
  }

  void updateTranscript(String text) {
    transcript.value = text;
  }

  void clearTranscript() {
    transcript.value = '';
  }

  /// Mock generation until API is connected.
  void generateResponses() {
    final base = transcript.value.isEmpty
        ? 'No input provided.'
        : transcript.value;
    responses.assignAll(<String>[
      'Sure, tomorrow 10 AM works for me.',
      'Can we do 10:30 AM instead?',
      'I am unavailable tomorrow, how about Friday?',
      'Let’s meet online via Zoom.',
      'Please share the agenda beforehand.',
      'Sounds good, see you then!',
    ]);
    selectedResponseIndex.value = -1;
  }

  void selectResponse(int index) {
    selectedResponseIndex.value = index;
  }

  String? get selectedResponse =>
      selectedResponseIndex.value >= 0 && selectedResponseIndex.value < responses.length
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
    responseText.value = list.first;
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
}
