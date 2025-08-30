import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/authentication/screens/login/login.dart';
import 'package:everyone_subtitle/Features/authentication/screens/onboarding/onboarding.dart';
import 'package:everyone_subtitle/Features/conversation/screens/speech_input_screen.dart';
import 'package:everyone_subtitle/Features/quiz/screens/quiz_intro_screen.dart';
import 'package:everyone_subtitle/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:everyone_subtitle/utils/exceptions/firebase_exceptions.dart';
import 'package:everyone_subtitle/utils/exceptions/format_exceptions.dart';
import 'package:everyone_subtitle/utils/exceptions/platform_exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  // Email verification is disabled for MVP; no verify controller needed

  @override
  void onReady() {
    super.onReady();
    screenRedirect();
  }

  /// Function to show the relevant screen
  screenRedirect() async {
    debugPrint('Test begin');
    final user = _auth.currentUser;

    if (user != null) {
      debugPrint('User found, checking quiz completion');

      // Check if user has completed the quiz (check Firestore first, then local storage)
      bool hasCompletedQuiz = false;

      try {
        // Check Firestore first
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          hasCompletedQuiz = data?['hasCompletedQuiz'] ?? false;

          // If found in Firestore, update local storage
          if (hasCompletedQuiz) {
            await deviceStorage.write('hasCompletedQuiz', true);
            // Also save the profile data locally if available
            if (data?['profile'] != null) {
              await deviceStorage.write('userProfile', data!['profile']);
            }
          }
        }
      } catch (e) {
        debugPrint('Error checking Firestore: $e');
        // Fall back to local storage if Firestore fails
        hasCompletedQuiz = deviceStorage.read('hasCompletedQuiz') ?? false;
      }

      if (hasCompletedQuiz) {
        debugPrint('Quiz completed, routing to Conversation');
        Get.offAll(() => const SpeechInputScreen());
      } else {
        debugPrint('Quiz not completed, routing to Quiz');
        Get.offAll(() => const QuizIntroScreen());
      }
    } else {
      debugPrint('No user, checking first time');
      // check if the first time opening the app
      await deviceStorage.writeIfNull('IsFirstTime', true);
      bool isFirstTime = deviceStorage.read('IsFirstTime');
      if (isFirstTime != true) {
        debugPrint('Not first time, routing to Login');
        Get.offAll(() => const LoginScreen());
      } else {
        debugPrint('First time, routing to Onboarding');
        Get.off(() => const onBoardingScreen());
      }
    }
  }

  /*----------------------------------- Email & Password sign-in -----------------------*/

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Somthing went Wrong';
    }
  }

  /// Email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Somthing went Wrong';
    }
  }

  /// Logout functuin
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Somthing went Wrong';
    }
  }

  /// signIn functuin
  Future<void> signIn(String email, String Password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: Password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Somthing went Wrong';
    }
  }
}
