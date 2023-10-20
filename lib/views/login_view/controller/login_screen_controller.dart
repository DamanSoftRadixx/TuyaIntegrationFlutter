import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:tuyaintegrationflutter/models/token_model.dart';
import 'package:tuyaintegrationflutter/res/common_ui/flutter_toast.dart';
import '../../../data/request.dart';
import '../../../repository/auth_provider.dart';

class LoginScreenController extends GetxController {
  AuthProvider authProvider = AuthProvider();
  RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }
  void gernateSignKey(){
    // str = client_id + t + nonce + stringToSign
    // sign = HMAC-SHA256(str, secret).toUpperCase()
    var currentTime  = DateTime.now().microsecondsSinceEpoch.toString();
    var str='ahx3majss889rgk5n9pq$currentTime';
    String signKey=calculateHMACSHA256("${str}GETe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855grant_type=1",'32c3d2e014374a67a3634a0cab616f50').toUpperCase();
    print('before up $signKey');

    print('ClientKey->-ahx3majss889rgk5n9pq-\ncurrentTime-$currentTime-\nstr-$str-signKey-$signKey-');
  }
  String calculateHMACSHA256(String input, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(input);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  void getToken() async {
    showToast('Clicked');
    RequestSignUtils.getTokenn();
    loading.value=true;
    Map<String, dynamic> parameter = {"grant_type":"1"};
    TokenModel? response = await authProvider.getToken(parameter: parameter);
    loading.value = false;
      print('response ${response.success}');
    if ((response.success ?? false) == true) {
      showToast('Token is ${response.result?.accessToken}');
    }

  }
  // String getSignKey()async{
  //   var keyStr=["GET","e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","","grant_type=1",];
  //
  // }

// Future<void> loginApi() async {
//   isLoading.value = true;
//   var deviceToken = await Prefs.read(AppStrings.deviceToken);
//
//
//   Map<String, dynamic> dataBody = {
//     "email": emailEditController.text.trim(),
//     "password": passwordEditController.text.trim(),
//     "device_type": Platform.isAndroid ? AppStrings.androidDevice : AppStrings.iosDevice,
//      "device_token": deviceToken,
//     // "device_token": 'tyr767ftytfy767',
//   };
//   LoginModel? response = await authProvider.loginRequest(body: dataBody);
//
//   print("responsee${response}");
//   isLoading.value = false;
//   print("test 200xdfcgvhbnkl;'${response?.status}");
//   if (response?.status == 200) {
//     print("test 200.......");
//     if((response?.data?.isVerified??-1)==1) {
//       Prefs.write(Prefs.TOKEN, response?.data?.deviceToken);
//       Get.put(DashboardController());
//       Get.offAllNamed(Routes.dashboard);
//     }else{
//       Get.toNamed(Routes.verifyCodeScreen,arguments: {
//         Arguments.emailKey: emailEditController.text.trim(),
//         Arguments.fromSignUpScreen:true,
//         Arguments.userPassword:passwordEditController.text.trim()
//       });
//     }
//   } else {
//     print("print the signup");
//   }
// }
}
