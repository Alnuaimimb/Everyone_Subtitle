import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/quiz/controllers/quiz_controller.dart';
import 'package:everyone_subtitle/Features/quiz/screens/quiz_result_screen.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';

class QuizQuestionScreen extends StatelessWidget {
  const QuizQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        title: const Text('Personality Quiz'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _showExitDialog(context),
            child: const Text('Exit'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Progress bar
              Obx(() {
                final controller = Get.find<QuizController>();
                return LinearProgressIndicator(
                  value: controller.progress,
                  backgroundColor: TColors.borderPrimary,
                  valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                );
              }),

              const SizedBox(height: 8),

              // Progress text
              Obx(() {
                final controller = Get.find<QuizController>();
                return Text(
                  'Question ${controller.currentIndex.value + 1} of ${controller.questions.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TColors.textSecondary,
                      ),
                );
              }),

              const SizedBox(height: 24),

              // Question card
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text
                        Obx(() {
                          final controller = Get.find<QuizController>();
                          return Text(
                            controller.currentQuestion.text,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: TColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          );
                        }),

                        const SizedBox(height: 32),

                        // Answer options
                        Expanded(
                          child: _buildAnswerOptions(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Navigation buttons
              SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Previous button
                    Obx(() {
                      final controller = Get.find<QuizController>();
                      return ElevatedButton(
                        onPressed: controller.canGoPrevious
                            ? controller.previousQuestion
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: TColors.textPrimary,
                          side: BorderSide(color: TColors.borderPrimary),
                        ),
                        child: const Text('Previous'),
                      );
                    }),

                    const Spacer(),

                    // Skip button (no Rx needed)
                    TextButton(
                      onPressed: Get.find<QuizController>().skipQuestion,
                      child: const Text('Skip'),
                    ),

                    const SizedBox(width: 12),

                    // Next/Finish button
                    Obx(() {
                      final controller = Get.find<QuizController>();
                      return ElevatedButton(
                        onPressed: controller.canGoNext
                            ? (controller.isLastQuestion
                                ? () => _finishQuiz(context, controller)
                                : controller.nextQuestion)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            Text(controller.isLastQuestion ? 'Finish' : 'Next'),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(BuildContext context) {
    return Obx(() {
      final controller = Get.find<QuizController>();
      final question = controller.currentQuestion;
      final selectedAnswer = controller.getSelectedAnswer();

      if (question.type == 'likert') {
        return ListView.builder(
          itemCount: question.options?.length ?? 0,
          itemBuilder: (context, index) {
            final option = question.options![index];
            final isSelected = selectedAnswer == option;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color:
                  isSelected ? TColors.primary.withOpacity(0.1) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? TColors.primary : TColors.borderPrimary,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.selectAnswer(option),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: selectedAnswer,
                        onChanged: (value) => controller.selectAnswer(value!),
                        activeColor: TColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: TColors.textPrimary,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        // Multi-choice
        return ListView.builder(
          itemCount: question.options?.length ?? 0,
          itemBuilder: (context, index) {
            final option = question.options![index];
            final isSelected = selectedAnswer == option;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color:
                  isSelected ? TColors.primary.withOpacity(0.1) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? TColors.primary : TColors.borderPrimary,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.selectAnswer(option),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? TColors.primary
                                : TColors.borderPrimary,
                            width: 2,
                          ),
                          color:
                              isSelected ? TColors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: TColors.textPrimary,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    });
  }

  void _finishQuiz(BuildContext context, QuizController controller) {
    if (controller.isComplete) {
      Get.to(() => const QuizResultScreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please answer all questions or skip them to continue.'),
        ),
      );
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
            'Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
