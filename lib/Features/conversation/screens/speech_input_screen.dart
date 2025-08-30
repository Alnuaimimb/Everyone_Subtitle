import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/Features/conversation/screens/response_suggestions_screen.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';

import 'package:everyone_subtitle/Features/settings/screens/settings_screen.dart';
import 'package:everyone_subtitle/Features/voice/controllers/voice_controller.dart';

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
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Obx(() {
                final voiceController = Get.find<VoiceController>();
                final currentVoice = voiceController.currentVoice;

                return CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(currentVoice.avatarPath),
                );
              }),
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
              // Live transcription indicator
              Obx(() => controller.isRecording.value
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: TColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: TColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Live Transcription Active',
                            style: TextStyle(
                              color: TColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
              if (controller.isRecording.value) const SizedBox(height: 12),
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
                      border: Border.all(
                        color: controller.isRecording.value
                            ? TColors.primary.withOpacity(0.3)
                            : TColors.borderPrimary,
                        width: controller.isRecording.value ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with status
                        Obx(() => Row(
                              children: [
                                Icon(
                                  controller.isRecording.value
                                      ? Icons.mic
                                      : Icons.mic_none,
                                  color: controller.isRecording.value
                                      ? TColors.primary
                                      : TColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  controller.isRecording.value
                                      ? 'Listening...'
                                      : 'Ready to listen',
                                  style: TextStyle(
                                    color: controller.isRecording.value
                                        ? TColors.primary
                                        : TColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 12),
                        // Transcript content
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Obx(() {
                              final transcriptText =
                                  controller.transcript.value;
                              final isRecording = controller.isRecording.value;

                              String displayText;
                              if (transcriptText.isNotEmpty) {
                                displayText = transcriptText;
                              } else if (isRecording) {
                                // While recording but no partial yet, show listening indicator
                                displayText = 'Listening...';
                              } else {
                                displayText = TTexts.transcriptPlaceholder;
                              }

                              return Text(
                                displayText,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: transcriptText.isNotEmpty
                                          ? TColors.textPrimary
                                          : TColors.textSecondary,
                                      height: 1.5,
                                    ),
                                // Force immediate text updates with unique key
                                key: ValueKey(
                                    'transcript_${transcriptText.hashCode}'),
                              );
                            }),
                          ),
                        ),
                        // Status indicator
                        Obx(() => controller.isRecording.value
                            ? Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 6,
                                      height: 6,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                TColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      controller.liveStatus.value.isNotEmpty
                                          ? controller.liveStatus.value
                                          : 'Processing...',
                                      style: TextStyle(
                                        color: TColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (controller
                                        .transcript.value.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 1,
                                        height: 12,
                                        color: TColors.primary.withOpacity(0.3),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${controller.transcript.value.split(' ').length} words',
                                        style: TextStyle(
                                          color: TColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            : const SizedBox.shrink()),
                      ],
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
                      // Play/Pause circular with processing state
                      Obx(() => AbsorbPointer(
                            absorbing: controller.isToggling.value ||
                                controller.isFinalizing.value ||
                                (controller.isLiveTranscribing.value &&
                                    !controller.isRecording.value),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _RoundActionButton(
                                  icon: controller.isRecording.isTrue
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  tooltip: controller.isRecording.isTrue
                                      ? TTexts.pause
                                      : TTexts.record,
                                  onPressed: (controller.isToggling.value ||
                                          controller.isFinalizing.value ||
                                          (controller
                                                  .isLiveTranscribing.value &&
                                              !controller.isRecording.value))
                                      ? null // Disable during processing
                                      : () async {
                                          await controller.toggleRecording();
                                          // Stay on this page after stop; user will press Generate.
                                        },
                                ),
                                // Processing circle overlay - also acts as click blocker
                                if (controller.isFinalizing.value ||
                                    (controller.isLiveTranscribing.value &&
                                        !controller.isRecording.value))
                                  GestureDetector(
                                    onTap: () {
                                      // Block all clicks during processing
                                      print(
                                          '[SpeechInputScreen] Blocked click during processing');
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    TColors.primary),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                      const SizedBox(width: 12),
                      // Reset circular
                      _RoundActionButton(
                        icon: Icons.refresh,
                        tooltip: TTexts.reset,
                        onPressed: () {
                          controller.resetConversation();
                        },
                      ),
                      const SizedBox(width: 12),
                      // Generate rectangular button fills remaining space
                      Expanded(
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.transcript.value.isEmpty
                                  ? null // Disable when no transcript
                                  : () async {
                                      if (controller.isRecording.value) {
                                        // Stop recording; user will generate on next step.
                                        await controller.toggleRecording();
                                      } else {
                                        // Generate single response if we have transcript
                                        if (controller
                                            .transcript.value.isNotEmpty) {
                                          await controller.generateResponses();
                                        }
                                      }
                                      Get.to(() =>
                                          const ResponseSuggestionsScreen());
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                backgroundColor: controller
                                        .transcript.value.isEmpty
                                    ? Colors.grey.shade400 // Gray when disabled
                                    : null, // Default color when enabled
                                foregroundColor: controller
                                        .transcript.value.isEmpty
                                    ? Colors.grey
                                        .shade600 // Gray text when disabled
                                    : null, // Default text color when enabled
                              ),
                              child: Text(
                                TTexts.generate,
                                style: TextStyle(
                                  color: controller.transcript.value.isEmpty
                                      ? Colors.grey.shade600
                                      : null,
                                ),
                              ),
                            )),
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
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: onPressed == null
              ? Colors.grey.shade400 // Gray when disabled
              : null, // Default color when enabled
          foregroundColor: onPressed == null
              ? Colors.grey.shade600 // Gray icon when disabled
              : null, // Default color when enabled
        ),
        child: Icon(
          icon,
          color: onPressed == null ? Colors.grey.shade600 : null,
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
