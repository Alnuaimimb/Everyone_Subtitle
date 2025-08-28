import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:event_app/Features/authentication/controllers/signup/verify_email_controller.dart';
import 'package:event_app/Features/authentication/screens/login/login.dart';
import 'package:event_app/Features/authentication/screens/onboarding/onboarding.dart';
import 'package:event_app/Features/authentication/screens/signup/verify_email.dart';
import 'package:event_app/navigation_menue.dart';
import 'package:event_app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:event_app/utils/exceptions/firebase_exceptions.dart';
import 'package:event_app/utils/exceptions/format_exceptions.dart';
import 'package:event_app/utils/exceptions/platform_exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final controller = Get.put(VerifyEmailController());

  @override
  void onReady() {
    super.onReady();
    FlutterNativeSplash.remove(); // Remove splash screen
    screenRedirect(); // Redirect to appropriate screen
  }

  /// Function to show the relevant screen
  screenRedirect() async {
    debugPrint('Test begin');
    final user = _auth.currentUser;
    // check if the user verfied
    if (user != null) {
      debugPrint('Test in 1');
      if (user.emailVerified) {
        debugPrint('Test in 2');
        Get.offAll(() => const NavigationMenue());
      } else {
        debugPrint('Test in 3');
        Get.offAll(VerifyEmail(email: user.email!));
      }
    } else {
      debugPrint('Test in 4');
      // check if the first time opening the app
      await deviceStorage.writeIfNull('IsFirstTime', true);
      bool isFirstTime = deviceStorage.read('IsFirstTime');
      if (isFirstTime != true) {
        debugPrint('Test in 5');
        Get.offAll(() => const LoginScreen());
      } else {
        debugPrint('Test in 16');

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
      _auth.currentUser!.sendEmailVerification();
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
