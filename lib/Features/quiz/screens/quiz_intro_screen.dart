import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/quiz/controllers/quiz_controller.dart';
import 'package:everyone_subtitle/Features/quiz/screens/quiz_question_screen.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';

class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        title: const Text('Personality Quiz'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon or illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology,
                  size: 60,
                  color: TColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Let\'s Get to Know You',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'This quick 30-question quiz will help us understand your communication style and personality. We\'ll use this information to generate responses that match your natural way of speaking.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TColors.textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Features list
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TColors.borderPrimary),
                ),
                child: Column(
                  children: [
                    _FeatureItem(
                      icon: Icons.timer,
                      text: 'Takes about 5-10 minutes',
                    ),
                    const SizedBox(height: 12),
                    _FeatureItem(
                      icon: Icons.security,
                      text: 'Your answers are private and secure',
                    ),
                    const SizedBox(height: 12),
                    _FeatureItem(
                      icon: Icons.auto_awesome,
                      text: 'Get personalized response suggestions',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Controller is already bound, just navigate
                    Get.off(() => const QuizQuestionScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: TColors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
