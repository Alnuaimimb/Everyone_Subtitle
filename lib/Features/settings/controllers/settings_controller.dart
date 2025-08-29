import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/settings/models/settings_user.dart';

class SettingsController extends GetxController {
  static SettingsController get instance => Get.put(SettingsController());

  final Rx<SettingsUser> user = const SettingsUser().obs;

  @override
  void onInit() {
    super.onInit();
    final u = FirebaseAuth.instance.currentUser;
    user.value = SettingsUser(
      displayName: u?.displayName ?? '',
      email: u?.email ?? '',
      photoUrl: u?.photoURL,
    );
  }
}

