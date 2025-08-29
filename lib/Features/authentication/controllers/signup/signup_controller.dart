// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/authentication/models/user_model.dart';
import 'package:everyone_subtitle/data/repositories/authentication/authentication_repository.dart';
import 'package:everyone_subtitle/data/repositories/user/user_repository.dart';
import 'package:everyone_subtitle/utils/constants/image_strings.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';

import 'package:everyone_subtitle/utils/helpers/network_manager.dart';
import 'package:everyone_subtitle/utils/popups/full_screen_loader.dart';
import 'package:everyone_subtitle/utils/popups/loaders.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables

  final hidePassword = true.obs;
  final privacyPolicy = true.obs;
  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  /// SignUp
  Future<void> signup() async {
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
      if (!signUpFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Check Privacy Policy
      if (!privacyPolicy.value) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
            title: TTexts.acceptPrivacyPolicyTitle,
            message: TTexts.acceptPrivacyPolicyMessage);
        FocusScope.of(Get.context!).unfocus();
      }

      // register user in the Firebase Authentication & save data in the firbase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim());

      // Save Authentication data to Firestore
      final newUser = UserModel(
          id: userCredential.user!.uid,
          username: userName.text,
          email: email.text,
          firstName: firstName.text,
          lastName: lastName.text,
          phoneNumber: phoneNumber.text,
          profilePicture: '');

      final userRepository = Get.put(UserRepository());
      await userRepository.SaveUserRecord(newUser);

      // stop loading
      TFullScreenLoader.stopLoading();

      // show success message
      TLoaders.successSnackBar(
          title: TTexts.Congratulatoions,
          message: TTexts.successfullSignUpMessage);

      // For MVP: go straight to Home via screenRedirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (error) {
      // show some generic error to the user
      TLoaders.warningSnackBar(title: 'Warrning', message: error.toString());
      TFullScreenLoader.stopLoading();
    }
  }
}
