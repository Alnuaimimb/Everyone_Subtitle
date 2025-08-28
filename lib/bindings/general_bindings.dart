import 'package:get/get.dart';
import 'package:event_app/Features/authentication/controllers/login_controller.dart';
import 'package:event_app/utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(LoginController());
  }
}
