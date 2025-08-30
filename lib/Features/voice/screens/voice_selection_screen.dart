import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/voice/controllers/voice_controller.dart';
import 'package:everyone_subtitle/Features/voice/widgets/voice_avatar_card.dart';
import 'package:everyone_subtitle/Features/conversation/screens/speech_input_screen.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';

class VoiceSelectionScreen extends StatelessWidget {
  const VoiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VoiceController controller = Get.find<VoiceController>();

    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        title: const Text(TTexts.voiceSelectionTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TTexts.voiceSelectionTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                TTexts.voiceSelectionSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Voice Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: controller.availableVoices.length,
                  itemBuilder: (context, index) {
                    final voice = controller.availableVoices[index];
                    return Obx(() {
                      final isSelected =
                          controller.selectedVoice.value?.id == voice.id;
                        return VoiceAvatarCard(
                          voice: voice,
                          isSelected: isSelected,
                          onTap: () => controller.previewVoice(voice),
                        );
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.selectedVoice.value != null
                          ? () => _onContinuePressed(context, controller)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        controller.selectedVoice.value != null
                            ? TTexts.voiceSelectionContinue
                            : TTexts.voiceSelectionSelectVoice,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinuePressed(BuildContext context, VoiceController controller) {
    // Save the selected voice
    controller.saveSelectedVoice();

    // Navigate to the main conversation screen
    Get.offAll(() => const SpeechInputScreen());
  }
}
