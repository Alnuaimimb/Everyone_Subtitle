import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/authentication/screens/signup/signup.dart';
import 'package:everyone_subtitle/data/repositories/authentication/authentication_repository.dart';
import 'package:everyone_subtitle/utils/constants/image_strings.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';
import 'package:everyone_subtitle/utils/helpers/network_manager.dart';
import 'package:everyone_subtitle/utils/popups/full_screen_loader.dart';
import 'package:everyone_subtitle/utils/popups/loaders.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/quiz/screens/quiz_intro_screen.dart';
import 'package:everyone_subtitle/Features/conversation/screens/speech_input_screen.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// Variables
  final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  /// Go to Sign Up
  void signup() {
    Get.to(const SignupScreen());
  }

  /// Log In using email and password
  void login() async {
    try {
      // check internet connection (no blocking full-screen loader)
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        return;
      }

      // Form Validation
      if (!logInFormKey.currentState!.validate()) return;

      // login the user
      await AuthenticationRepository.instance.signIn(email.text, password.text);

      // Redirect immediately without intermediate loader
      final hasCompletedQuiz = GetStorage().read('hasCompletedQuiz') ?? false;
      if (hasCompletedQuiz) {
        Get.offAll(() => const SpeechInputScreen());
      } else {
        Get.offAll(() => const QuizIntroScreen());
      }
      // Optionally still allow background sync via auth repo (non-blocking)
      // ignore: unawaited_futures
      Future.microtask(() => AuthenticationRepository.instance.screenRedirect());
      TLoaders.successSnackBar(
        title: TTexts.homeGreeting,
        message: TTexts.successfullLogInMessage,
      );
    } catch (error) {
      // show some generic error to the user
      TLoaders.warningSnackBar(title: 'Warrning', message: error.toString());
    }
  }

  /// Logout
  void logout() async {
    await AuthenticationRepository.instance.logout();
    await FirebaseAuth.instance.currentUser!.reload();
  }
}
