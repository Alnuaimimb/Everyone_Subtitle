import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/Features/conversation/screens/final_response_screen.dart';
import 'package:everyone_subtitle/Features/voice/controllers/voice_controller.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';
import 'package:everyone_subtitle/utils/constants/image_strings.dart';
import 'package:everyone_subtitle/Features/settings/screens/settings_screen.dart';
import 'package:everyone_subtitle/data/services/profile/profile_improvement_service.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';

/// Page 2: Shows a smaller, scrollable transcript card and a scrollable grid of responses.
class ResponseSuggestionsScreen extends StatefulWidget {
  const ResponseSuggestionsScreen({super.key});

  @override
  State<ResponseSuggestionsScreen> createState() =>
      _ResponseSuggestionsScreenState();
}

class _ResponseSuggestionsScreenState extends State<ResponseSuggestionsScreen> {
  @override
  void initState() {
    super.initState();
    // Generate option buttons when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ConversationController.instance;
      if (controller.transcript.value.isNotEmpty &&
          controller.optionButtons.isEmpty) {
        controller.generateOptionButtons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ConversationController.instance;

    final ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(TTexts.responsesTitle),
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
                  onBackgroundImageError: (exception, stackTrace) {
                    // Fallback to default user image
                  },
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
              // Top response card with scrollbar
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          child: Obx(() => SingleChildScrollView(
                                controller: scrollController,
                                child: Text(
                                  controller.responseText.value.isEmpty
                                      ? TTexts.chooseOptionPrompt
                                      : controller.responseText.value,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              )),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: controller.responseText.value.isEmpty
                                ? null
                                : () {
                                    final text = controller.responseText.value;
                                    // Save response choice for profile improvement
                                    ProfileImprovementService
                                        .saveResponseChoice(
                                      transcript: controller.transcript.value,
                                      selectedResponse: text,
                                    );
                                    Get.to(() => const FinalResponseScreen());
                                  },
                            child: const Text(TTexts.select),
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Dynamic option buttons
              Obx(() => controller.isGeneratingOptions.value
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  TColors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Generating options...',
                            style: TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : controller.optionButtons.isNotEmpty
                      ? Column(
                          children: [
                            Text(
                              'Choose an option:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: TColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: TColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: TColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      controller.selectOption(0);
                                    },
                                    child: Text(
                                      controller.optionButtons[0],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: TColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: TColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      controller.selectOption(1);
                                    },
                                    child: Text(
                                      controller.optionButtons[1],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink()),

              const SizedBox(height: 12),

              // Bottom actions: Custom button above Generate New Response
              SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Custom Button (Full Width)
                    ElevatedButton(
                      onPressed: () async {
                        // Prompt for custom text
                        final text = await showDialog<String>(
                          context: context,
                          builder: (ctx) {
                            final TextEditingController tc =
                                TextEditingController();
                            return AlertDialog(
                              title: const Text(TTexts.custom),
                              content: Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 150,
                                  minHeight: 80,
                                ),
                                child: TextField(
                                  controller: tc,
                                  maxLines: 4,
                                  minLines: 2,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your custom response...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text(TTexts.cancel)),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, tc.text.trim()),
                                    child: const Text(TTexts.ok)),
                              ],
                            );
                          },
                        );
                        if (text != null && text.isNotEmpty) {
                          controller.responseText.value = text;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: TColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(TTexts.custom),
                    ),
                    const SizedBox(height: 12),
                    // Generate New Response Button (Full Width)
                    Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: controller.isGeneratingNewResponse.value
                              ? null
                              : () async {
                                  // Generate new option buttons and responses
                                  await controller.generateOptionButtons();
                                  // Also generate a new single response
                                  await controller.generateResponses();
                                },
                          child: controller.isGeneratingNewResponse.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Generating...'),
                                  ],
                                )
                              : const Text(TTexts.generateNewResponse),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Old tone card removed (unused)
