import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';

/// Page 2: Shows a smaller, scrollable transcript card and a scrollable grid of responses.
class ResponseSuggestionsScreen extends StatelessWidget {
  const ResponseSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ConversationController.instance;

    final ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(title: const Text('Responses')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top response card with scrollbar
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  height: 180,
                  padding: const EdgeInsets.all(16.0),
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: Obx(() => SingleChildScrollView(
                          controller: scrollController,
                          child: Text(
                            controller.responseText.value.isEmpty
                                ? 'Choose an option below to generate a response.'
                                : controller.responseText.value,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // A/B row like wireframe
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.generateForTone('Agree'),
                      child: const Text('A'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.generateForTone('Disagree'),
                      child: const Text('B'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom actions: red and green buttons
              SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Prompt for custom text
                          final text = await showDialog<String>(
                            context: context,
                            builder: (ctx) {
                              final TextEditingController tc =
                                  TextEditingController();
                              return AlertDialog(
                                title: const Text('Custom'),
                                content: TextField(controller: tc, maxLines: 3),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, tc.text.trim()),
                                      child: const Text('OK')),
                                ],
                              );
                            },
                          );
                          if (text != null && text.isNotEmpty) {
                            controller.responseText.value = text;
                          }
                        },
                        child: const Text('Custom'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.responseText.value.isEmpty) {
                            Get.snackbar('Select', 'Choose an option first',
                                snackPosition: SnackPosition.BOTTOM);
                          } else {
                            Get.snackbar(
                                'Selected', controller.responseText.value,
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        },
                        child: const Text('Generate'),
                      ),
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
