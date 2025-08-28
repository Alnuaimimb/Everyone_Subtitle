import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:event_app/Features/authentication/models/user_model.dart';
import 'package:event_app/Features/authentication/screens/login/login.dart';
import 'package:event_app/Features/authentication/screens/onboarding/onboarding.dart';
import 'package:event_app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:event_app/utils/exceptions/firebase_exceptions.dart';
import 'package:event_app/utils/exceptions/format_exceptions.dart';
import 'package:event_app/utils/exceptions/platform_exceptions.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _db = FirebaseFirestore.instance;

  Future<void> SaveUserRecord(UserModel user) async {
    try {
      return _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseAuthException catch (e) {
      TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      const TFormatException();
    } on PlatformException catch (e) {
      TPlatformException(e.code).message;
    } catch (e) {
      'Somthing went Wrong, Please try again later';
    }
  }
}
