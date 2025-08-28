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
      // start Loading
      TFullScreenLoader.openLoadingDialog(
          TTexts.signupLoadingMesaage, TImages.applePay);

      // check internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!logInFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // login the user
      await AuthenticationRepository.instance.signIn(email.text, password.text);

      // stop loading
      TFullScreenLoader.stopLoading();

      // show success message
      TLoaders.successSnackBar(
          title: TTexts.Congratulatoions,
          message: TTexts.successfullLogInMessage);

      // redirect to navigation screen
      AuthenticationRepository.instance.screenRedirect();
    } catch (error) {
      // show some generic error to the user
      TLoaders.warningSnackBar(title: 'Warrning', message: error.toString());
      TFullScreenLoader.stopLoading();
    }
  }

  /// Logout
  void logout() async {
    await AuthenticationRepository.instance.logout();
    await FirebaseAuth.instance.currentUser!.reload();
  }
}
