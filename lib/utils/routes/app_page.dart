
import 'package:get/get.dart';
import 'package:tuyaintegrationflutter/views/login_view/binding/login_screen_binding.dart';
import 'package:tuyaintegrationflutter/views/login_view/screens/login_screen.dart';

class Routes {
  Routes._();

  static const String INITIAL = "/";

  static const String loginScreen="/loginScreen";
  static const String signupScreen="/signupScreen";
  static const Transition transition = Transition.rightToLeft;
  static const int transitionDuration = 320;
}

List<GetPage> AppPages() => [

  GetPage(
    name: Routes.INITIAL,
    page: () =>  const LoginScreen(),
    fullscreenDialog: true,
    binding: LoginScreenBinding(),
    transition: Routes.transition,
    transitionDuration: const Duration(milliseconds: Routes.transitionDuration),
  ),
];