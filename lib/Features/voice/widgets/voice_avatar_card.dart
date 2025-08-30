import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/voice/models/voice_model.dart';
import 'package:everyone_subtitle/Features/voice/controllers/voice_controller.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';

class VoiceAvatarCard extends StatelessWidget {
  final VoiceModel voice;
  final bool isSelected;
  final VoidCallback onTap;

  const VoiceAvatarCard({
    super.key,
    required this.voice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TColors.primary : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? TColors.primary : Colors.grey.shade300,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  voice.avatarPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        voice.gender == 'male'
                            ? Icons.person
                            : Icons.person_outline,
                        size: 30,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Voice Name
            Text(
              voice.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 2),

            // Selection Indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 2),

            // Preview Button
            if (isSelected)
              Obx(() {
                final controller = Get.find<VoiceController>();
                final isPreviewing = controller.isPreviewing.value;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: isPreviewing ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPreviewing)
                        const SizedBox(
                          width: 6,
                          height: 6,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      if (isPreviewing) const SizedBox(width: 2),
                      Text(
                        isPreviewing ? 'Gen...' : 'Preview',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
