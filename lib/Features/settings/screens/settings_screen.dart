import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:everyone_subtitle/Features/quiz/screens/quiz_intro_screen.dart';
import 'package:everyone_subtitle/Features/voice/screens/voice_selection_screen.dart';
import 'package:everyone_subtitle/Features/authentication/screens/login/login.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        title: const Text(TTexts.settingAppbarTitle),
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
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 24),

              // Profile Section
              _buildSection(
                context,
                title: 'Profile',
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.psychology,
                    title: 'Personality Quiz',
                    subtitle: 'Retake the personality assessment',
                    onTap: () => _showRetakeQuizDialog(context),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.person,
                    title: 'View Profile',
                    subtitle: 'See your communication style analysis',
                    onTap: () => _showProfileDialog(context),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.record_voice_over,
                    title: 'AI Voice',
                    subtitle: 'Change your AI assistant voice',
                    onTap: () => Get.to(() => const VoiceSelectionScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // App Section
              _buildSection(
                context,
                title: 'App',
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),

              const Spacer(),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: TColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: TColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: TColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TColors.textSecondary,
            ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: TColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showRetakeQuizDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retake Personality Quiz'),
        content: const Text(
          'This will reset your current personality profile. Are you sure you want to retake the quiz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuizAndStart();
            },
            child: const Text('Retake Quiz'),
          ),
        ],
      ),
    );
  }

  void _resetQuizAndStart() async {
    final storage = GetStorage();
    await storage.remove('hasCompletedQuiz');
    await storage.remove('userProfile');

    Get.offAll(() => const QuizIntroScreen());
  }

  void _showProfileDialog(BuildContext context) async {
    final storage = GetStorage();
    final profileData = storage.read('userProfile');

    if (profileData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No profile found. Please complete the quiz first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Communication Profile'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Summary:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(profileData['summary'] ?? 'No summary available'),
              const SizedBox(height: 16),
              Text(
                'Speaking Style:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(profileData['speaking_style'] ?? 'Not specified'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Everyone Subtitle'),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text(
                'An AI-powered communication assistant that helps you express yourself naturally.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Clear all local data
              final storage = GetStorage();
              await storage.remove('selectedVoice');
              await storage.remove('hasCompletedQuiz');
              await storage.remove('userProfile');
              await storage.remove('responseHistory');

              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // Navigate to login screen
              Get.offAll(() => const LoginScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
