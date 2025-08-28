import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/authentication/controllers/login_controller.dart';
import 'package:everyone_subtitle/utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
<<<<<<< HEAD
    Get.put(LoginController()); //ddddddd
=======
    Get.put(LoginController());//mjmjmjmjyubjjbj
>>>>>>> e37ef248c69555229a48d4b826264c761d84c36f
  }
}
