import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/controllers/conversation_controller.dart';
import 'package:everyone_subtitle/Features/conversation/screens/speech_input_screen.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';

class FinalResponseScreen extends StatelessWidget {
  const FinalResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConversationController>();

    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        title: const Text('Your Response'),
        backgroundColor: TColors.lightGrey,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Response Card
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.message,
                              color: TColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Your Response',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: TColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Obx(() => Text(
                            controller.responseText.value.isEmpty 
                                ? 'No response selected' 
                                : controller.responseText.value,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              height: 1.5,
                              color: TColors.textPrimary,
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Speak Button
                    Obx(() => ElevatedButton(
                      onPressed: controller.responseText.value.isEmpty
                          ? null
                          : () async {
                              await controller.speakResponse();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => Icon(
                            controller.isSpeaking.value ? Icons.stop : Icons.volume_up,
                            size: 24,
                          )),
                          const SizedBox(width: 12),
                          Obx(() => Text(
                            controller.isSpeaking.value ? 'Stop Speaking' : 'Speak Response',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                        ],
                      ),
                    )),
                    
                    const SizedBox(height: 16),
                    
                    // Back to Listening Button
                    OutlinedButton(
                      onPressed: () {
                        // Save response to history and improve profile
                        controller.saveResponseToHistory();
                        // Navigate back to speech input
                        Get.offAll(() => const SpeechInputScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.primary,
                        side: BorderSide(color: TColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.hearing, size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            'Back to Listening',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
