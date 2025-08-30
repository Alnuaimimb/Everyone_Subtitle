import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/Features/conversation/screens/final_response_screen.dart';
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
                                      backgroundColor: TColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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
                                      backgroundColor: TColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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

              // Bottom actions: centered Generate New Response and full-width Custom
              SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 260,
                        child: Obx(() => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: controller
                                      .isGeneratingNewResponse.value
                                  ? null
                                  : () async {
                                      // Generate new option buttons and responses
                                      await controller.generateOptionButtons();
                                      // Also generate a new single response
                                      await controller.generateResponses();
                                    },
                              child: controller.isGeneratingNewResponse.value
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        // Prompt for custom text
                        final text = await showDialog<String>(
                          context: context,
                          builder: (ctx) {
                            final TextEditingController tc =
                                TextEditingController();
                            return AlertDialog(
                              title: const Text(TTexts.custom),
                              content: TextField(controller: tc, maxLines: 3),
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
                      child: const Text(TTexts.custom),
                    ),
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
