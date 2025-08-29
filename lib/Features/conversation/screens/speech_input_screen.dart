import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/Features/conversation/screens/response_suggestions_screen.dart';

/// Page 1: Shows the speech-to-text card and controls row.
class SpeechInputScreen extends StatelessWidget {
  const SpeechInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConversationController());

    // ScrollController reserved if needed later for transcript scrolling.

    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(title: const Text('Speech to Text')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Transcript card - fills most of the screen
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TColors.borderPrimary),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Obx(() => Text(
                            controller.transcript.value.isEmpty
                                ? 'Start speaking to see the transcript here...'
                                : controller.transcript.value,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: TColors.textPrimary),
                          )),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom controls as in the wireframe
              SafeArea(
                top: false,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Play/Pause circular
                      Obx(() => _RoundActionButton(
                            icon: controller.isRecording.isTrue
                                ? Icons.pause
                                : Icons.play_arrow,
                            onPressed: controller.toggleRecording,
                          )),
                      const SizedBox(width: 12),
                      // Reset circular
                      _RoundActionButton(
                        icon: Icons.refresh,
                        onPressed: () {
                          controller.clearTranscript();
                          controller.isRecording.value = false;
                        },
                      ),
                      const SizedBox(width: 12),
                      // Generate rectangular button fills remaining space
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.generateResponses();
                            Get.to(() => const ResponseSuggestionsScreen());
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56)),
                          child: const Text('Generate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(shape: const CircleBorder()),
        child: Icon(icon),
      ),
    );
  }
}
