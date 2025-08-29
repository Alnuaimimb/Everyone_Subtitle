// FIX THE EMAIL

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everyone_subtitle/data/repositories/authentication/authentication_repository.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';
import 'package:everyone_subtitle/utils/popups/loaders.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  @override
  void onInit() async {
    super.onInit();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        debugPrint("User is logged in: ${user.email}");
      } else {
        debugPrint("No user is logged in");
      }
    });

    sendEmailVerification();
    setTimerForAutoRedirect();
  }

  /// Send email verification link
  sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      TLoaders.successSnackBar(
          title: "Email Sent",
          message: "Please check your inbox and click the verification link.");
    } catch (e) {
      TLoaders.errorSnackBar(title: TTexts.error, message: e.toString());
    }
  }

  /// Timer to automatically redirect on email verification
  setTimerForAutoRedirect() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("User is still null");
        return;
      }

      await user.reload();
      if (user.emailVerified) {
        timer.cancel();
        // Route directly to HomeScreen after verification
        AuthenticationRepository.instance.screenRedirect();
      }
    });
  }

  /// Manual check if email is verified (using the button)

  checkEmailVerificationStatus() async {
    debugPrint("Checking email verification status...");
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();

    if (user.emailVerified) {
      debugPrint('Email is verified');

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isEmailVerified", true);

      // Route directly to HomeScreen after verification
      AuthenticationRepository.instance.screenRedirect();
    } else {
      debugPrint("Email not verified yet");
    }
  }
}
