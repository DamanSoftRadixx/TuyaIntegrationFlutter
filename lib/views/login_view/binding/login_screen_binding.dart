import 'package:get/get.dart';

import '../controller/login_screen_controller.dart';

class LoginScreenBinding implements Bindings{

  @override
  void dependencies() {

    Get.lazyPut<LoginScreenController>(() => LoginScreenController());

  }

}