import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/authentication/controllers/login_controller.dart';
import 'package:everyone_subtitle/utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(LoginController()); //ddddddd
  }
}
