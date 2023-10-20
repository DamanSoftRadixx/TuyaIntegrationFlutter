
import 'dart:convert';
import 'dart:developer';

import 'package:tuyaintegrationflutter/data/network/apiendpoint.dart';
import 'package:tuyaintegrationflutter/models/token_model.dart';

import '../data/network/api_hitter.dart';
import '../res/common_ui/flutter_toast.dart';

class AuthProvider{
  ApiHitter apiHitter = ApiHitter();

  Future<dynamic> loginRequest({required Map<String,dynamic> body}) async {
    try {
      var response = await apiHitter.postApi(
          endPoint: ApiEndPoint.LOGIN_URL,
          body: body
      );
      log("response\-----$response");
      print('response back £££££${response}££££££££');
      return response.data;
      // return LoginModel.fromJson(response.data);
    } catch (e) {
      log("Error>> ${e.toString()}");
    }
  }

  Future<TokenModel> getToken({required Map<String,dynamic> parameter})async{
    var response = await apiHitter.getApi(
        endPoint: ApiEndPoint.getToken,
      queryParameters: parameter
    );
    print('response is ${response}');
    showToast('Token is ${response.data['msg']}');
    return TokenModel.fromJson(response.data);
  }



}