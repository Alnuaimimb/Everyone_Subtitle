import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/quiz/controllers/quiz_controller.dart';
import 'package:everyone_subtitle/Features/quiz/models/user_profile.dart';
import 'package:everyone_subtitle/data/services/ai/openai_service.dart';
import 'package:everyone_subtitle/Features/conversation/screens/speech_input_screen.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/popups/loaders.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool _isGenerating = true;
  UserProfile? _profile;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateProfile();
  }

  Future<void> _generateProfile() async {
    try {
      final controller = Get.find<QuizController>();
      final answers = controller.getAnswersForAI();

      // Generate profile using OpenAI
      final profile = await OpenAIService.generateUserProfile(answers);

      // Save to Firestore
      await _saveProfileToFirestore(profile);

      // Save to local storage
      await _saveProfileToLocal(profile);

      setState(() {
        _profile = profile;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isGenerating = false;
      });
    }
  }

  Future<void> _saveProfileToFirestore(UserProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .set({
          'hasCompletedQuiz': true,
          'profile': profile.toJson(),
          'quizCompletedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
      } catch (_) {
        // Ignore network errors/timeouts; proceed with local save.
      }
    }
  }

  Future<void> _saveProfileToLocal(UserProfile profile) async {
    final storage = GetStorage();
    await storage.write('hasCompletedQuiz', true);
    await storage.write('userProfile', profile.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        title: const Text('Building Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isGenerating ? _buildLoadingView() : _buildResultView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Loading animation
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Analyzing Your Responses...',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: TColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          'We\'re creating your personalized communication profile. This will help us generate responses that match your natural speaking style.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: TColors.textSecondary,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultView() {
    if (_error != null) {
      return _buildErrorView();
    }

    if (_profile == null) {
      return _buildErrorView();
    }

    return Column(
      children: [
        // Success icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: TColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 60,
            color: TColors.success,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Profile Created Successfully!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: TColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Profile summary card
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Communication Style',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: TColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profile!.summary,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: TColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Key Traits',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: TColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _profile!.traits
                        .map((trait) => Chip(
                              label: Text(trait),
                              backgroundColor: TColors.primary.withOpacity(0.1),
                              labelStyle: TextStyle(color: TColors.primary),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Speaking Style',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: TColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profile!.speakingStyle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Get.offAll(() => const SpeechInputScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Using Your Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 80,
          color: TColors.error,
        ),
        const SizedBox(height: 24),
        Text(
          'Something went wrong',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: TColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          _error ?? 'Unable to generate your profile. Please try again.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: TColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isGenerating = true;
                    _error = null;
                  });
                  _generateProfile();
                },
                child: const Text('Try Again'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => const SpeechInputScreen());
                },
                child: const Text('Skip for Now'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
