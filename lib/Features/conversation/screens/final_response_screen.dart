import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/Features/conversation/screens/speech_input_screen.dart';
import 'package:everyone_subtitle/data/services/ai/tts_service.dart';
import 'package:everyone_subtitle/data/services/profile/profile_improvement_service.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';

class FinalResponseScreen extends StatefulWidget {
  const FinalResponseScreen({super.key});

  @override
  State<FinalResponseScreen> createState() => _FinalResponseScreenState();
}

class _FinalResponseScreenState extends State<FinalResponseScreen> {
  final ConversationController controller = Get.find<ConversationController>();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await TTSService.initialize();
  }

  Future<void> _speakResponse() async {
    if (isSpeaking) {
      await TTSService.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      setState(() {
        isSpeaking = true;
      });

      await TTSService.speak(controller.responseText.value);

      // Reset speaking state after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isSpeaking = false;
          });
        }
      });
    }
  }

  void _saveResponseChoice() {
    ProfileImprovementService.saveResponseChoice(
      transcript: controller.transcript.value,
      selectedResponse: controller.responseText.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        title: const Text('Your Response'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Response Card
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.message,
                              color: TColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              TTexts.yourResponse,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: TColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Obx(() => Text(
                                  controller.responseText.value.isEmpty
                                      ? 'No response selected'
                                      : controller.responseText.value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: TColors.textPrimary,
                                        height: 1.5,
                                      ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // TTS Button
              SizedBox(
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: _speakResponse,
                  icon: Icon(
                    isSpeaking ? Icons.stop : Icons.volume_up,
                    size: 28,
                  ),
                  label: Text(
                    isSpeaking ? TTexts.stopSpeaking : TTexts.speakResponse,
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSpeaking ? Colors.red : TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _saveResponseChoice();
                        Get.offAll(() => const SpeechInputScreen());
                      },
                      icon: const Icon(Icons.mic),
                      label: const Text(TTexts.backToListening),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _saveResponseChoice();
                        Get.back(); // Go back to response suggestions
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text(TTexts.changeResponse),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    TTSService.stop();
    super.dispose();
  }
}
