import 'package:flutter/material.dart';
import 'package:everyone_subtitle/Features/voice/models/voice_model.dart';
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
              width: 80,
              height: 80,
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
                        voice.gender == 'female'
                            ? Icons.person
                            : Icons.person_outline,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Voice Name
            Text(
              voice.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),

            // Voice Type
            Text(
              voice.voiceType[0].toUpperCase() + voice.voiceType.substring(1),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),

            // Selection Indicator
            if (isSelected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  TTexts.voiceSelected,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            
            // Preview Button
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  TTexts.voicePreview,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
