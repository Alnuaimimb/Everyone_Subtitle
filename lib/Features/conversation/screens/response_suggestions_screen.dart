import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';
import 'package:everyone_subtitle/utils/constants/image_strings.dart';
import 'package:everyone_subtitle/Features/settings/screens/settings_screen.dart';
import 'package:everyone_subtitle/Features/conversation/screens/final_response_screen.dart';

/// Page 2: Shows a smaller, scrollable transcript card and a scrollable grid of responses.
class ResponseSuggestionsScreen extends StatelessWidget {
  const ResponseSuggestionsScreen({super.key});

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
                                    Get.to(() => const FinalResponseScreen());
                                  },
                            child: const Text(TTexts.select),
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // A/B row like wireframe
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: () {
                            controller.applyOptionA();
                          },
                          child: Text(
                            controller.responseA.value.isEmpty
                                ? 'Option A'
                                : controller.responseA.value,
                          ),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: () {
                            controller.applyOptionB();
                          },
                          child: Text(
                            controller.responseB.value.isEmpty
                                ? 'Option B'
                                : controller.responseB.value,
                          ),
                        )),
                  ),
                ],
              ),
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await controller.generateResponses();
                          },
                          child: const Text(TTexts.generateNewResponse),
                        ),
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
