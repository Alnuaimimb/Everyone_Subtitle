import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/data/repositories/authentication/authentication_repository.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';
import 'package:everyone_subtitle/utils/helpers/network_manager.dart';
import 'package:everyone_subtitle/utils/popups/loaders.dart';
import 'package:everyone_subtitle/utils/validators/validation.dart';
import 'package:everyone_subtitle/Features/authentication/screens/login/login.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  /// Variables
  final GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();
  final email = TextEditingController();

  /// Send password reset email
  Future<void> sendPasswordResetEmail() async {
    try {
      // Check internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        return;
      }

      // Form validation
      if (!forgetPasswordFormKey.currentState!.validate()) return;

      // Send password reset email
      await AuthenticationRepository.instance
          .sendPasswordResetEmail(email.text.trim());

      // Show success message
      TLoaders.successSnackBar(
        title: TTexts.changeYourPasswordTitle,
        message: TTexts.changeYourPasswordSubTitle,
      );

      // Navigate back to login screen
      Get.offAll(() => const LoginScreen());
    } catch (error) {
      // Show error message
      TLoaders.errorSnackBar(
        title: TTexts.error,
        message: error.toString(),
      );
    }
  }
}
