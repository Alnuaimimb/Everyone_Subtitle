import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/Features/conversation/screens/speech_input_screen.dart';
import 'package:everyone_subtitle/Features/voice/controllers/voice_controller.dart';
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
  }

  Future<void> _speakResponse() async {
    if (isSpeaking) {
      setState(() {
        isSpeaking = false;
      });
    } else {
      setState(() {
        isSpeaking = true;
      });

      await controller.speakResponse();

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
                  color: Colors.purple.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.message,
                                color: TColors.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              TTexts.yourResponse,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: TColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(right: 2),
                            child: Obx(() => SelectableText(
                                  controller.responseText.value.isEmpty
                                      ? 'No response selected'
                                      : controller.responseText.value,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: TColors.textPrimary,
                                        fontSize: 16,
                                        height: 1.6,
                                        letterSpacing: 0.2,
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

              // Voice Indicator
              Obx(() {
                final voiceController = Get.find<VoiceController>();
                final currentVoice = voiceController.currentVoice;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage(currentVoice.avatarPath),
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Speaking with ${currentVoice.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${currentVoice.gender[0].toUpperCase() + currentVoice.gender.substring(1)} voice',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        currentVoice.gender == 'male'
                            ? Icons.person
                            : Icons.person_outline,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

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

              // Navigation Buttons (side by side)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _saveResponseChoice();
                        Get.offAll(() => const SpeechInputScreen());
                      },
                      icon: const Icon(Icons.mic, size: 18),
                      label: const Text(
                        TTexts.backToListening,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: TColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _saveResponseChoice();
                        Get.back(); // Back to suggestions
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                        TTexts.changeResponse,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: TColors.primary, width: 1.5),
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
    super.dispose();
  }
}
