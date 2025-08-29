import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/Features/conversation/screens/response_suggestions_screen.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';
import 'package:everyone_subtitle/utils/constants/image_strings.dart';
import 'package:everyone_subtitle/Features/settings/screens/settings_screen.dart';

/// Page 1: Shows the speech-to-text card and controls row.
class SpeechInputScreen extends StatelessWidget {
  const SpeechInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConversationController());

    // ScrollController reserved if needed later for transcript scrolling.

    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        title: const Text(TTexts.speechToTextTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') Get.to(() => const SettingsScreen());
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                  value: 'settings', child: Text(TTexts.settingAppbarTitle)),
            ],
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(TImages.user),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
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
                      child: Obx(() {
                        final transcriptText = controller.transcript.value;
                        final isRecording = controller.isRecording.value;

                        String displayText;
                        if (transcriptText.isNotEmpty) {
                          displayText = transcriptText;
                        } else if (isRecording) {
                          displayText = 'Listening... Speak now...';
                        } else {
                          displayText = TTexts.transcriptPlaceholder;
                        }

                        return Text(
                          displayText,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: TColors.textPrimary),
                        );
                      }),
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
                            tooltip: controller.isRecording.isTrue
                                ? TTexts.pause
                                : TTexts.record,
                            onPressed: () async {
                              await controller.toggleRecording();
                              // Stay on this page after stop; user will press Generate.
                            },
                          )),
                      const SizedBox(width: 12),
                      // Reset circular
                      _RoundActionButton(
                        icon: Icons.refresh,
                        tooltip: TTexts.reset,
                        onPressed: () {
                          controller.clearTranscript();
                          controller.isRecording.value = false;
                        },
                      ),

                      // Test button (temporary)
                      const SizedBox(width: 12),
                      _RoundActionButton(
                        icon: Icons.bug_report,
                        tooltip: 'Test',
                        onPressed: () async {
                          // Test single response generation
                          controller.transcript.value = 'How are you today?';
                          await controller.generateResponses();
                        },
                      ),
                      const SizedBox(width: 12),
                      // Generate rectangular button fills remaining space
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (controller.isRecording.value) {
                              // Stop recording; user will generate on next step.
                              await controller.toggleRecording();
                            } else {
                              // Generate single response if we have transcript
                              if (controller.transcript.value.isNotEmpty &&
                                  controller.transcript.value !=
                                      'Listening... Speak now...') {
                                await controller.generateResponses();
                              }
                            }
                            Get.to(() => const ResponseSuggestionsScreen());
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56)),
                          child: const Text(TTexts.generate),
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
  const _RoundActionButton(
      {required this.icon, required this.onPressed, this.tooltip});
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(shape: const CircleBorder()),
        child: Icon(icon),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
