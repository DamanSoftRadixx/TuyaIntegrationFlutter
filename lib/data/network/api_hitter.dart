import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;

import 'package:get/get_core/src/get_main.dart';
import 'package:tuyaintegrationflutter/data/network/apiendpoint.dart';

import '../../res/storge/local_storage.dart';
import 'dio_exceptions.dart';
import 'network_check.dart';


class ApiHitter {
  static Dio dio = Dio();
  static CancelToken cancelToken = CancelToken();
  final GlobalKey key = GlobalKey();
  NetworkCheck networkCheck = NetworkCheck();
  final cancelTokenStatusCode = "10000";
  final Duration duration=const Duration(seconds: 10);
  postApi(
      {required String endPoint,
        Object? body,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
        bool isCancelToken = false,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headersParm}) async {
    try {
      String url = "${ApiEndPoint.BASE_URL}$endPoint";
      print("URL $endPoint >> $url");
      print("POST $endPoint >> $body");
      print("POST $endPoint >> $queryParameters");

      if (await networkCheck.hasNetwork()) {
        if (isCancelToken) {
          cancelToken.cancel();

          if (cancelToken.isCancelled) {
            cancelToken = CancelToken();
          }
        }

        String token = await Prefs.read(Prefs.TOKEN) ?? "";

        log("token>>>>>>> $token");

        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'authorization': "Bearer $token",
        };
        log("headers>> $headers");

        headers.addAll(headersParm ?? {});

        Options options = Options(headers: headers);

        var response = await dio.post(
          url,
          options: options,
          data: body,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
          queryParameters: queryParameters,
        ).timeout(duration);



        var statusCode = response.data["status"] ?? 400;
        var statusMessage = response.data["message"] ?? 400;
        if (statusCode == 201 || statusCode == 200) {
          return response;
        } else {
          apiErrorDialog(
            message: statusMessage ?? "",
            okButtonPressed: () {
              Get.back();
            },
          );
        }

        log("response>>>>>> $response");
      } else {
        log("no internet issue");
        networkCheck.noInternetConnectionDialog();
      }
    } catch (e) {
      if (e is DioException) {
        if(e.type == DioExceptionType.cancel){
          return Response(data: {
            "status" : cancelTokenStatusCode,
          }, requestOptions: RequestOptions());
        }
        throw DioExceptions.fromDioError(dioError: e);
      } else {
        throw Exception("Error");
      }
    }
  }

  putApi(
      {required String endPoint,
        Object? body,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
        bool isCancelToken = false,
        Map<String, dynamic>? queryParameters}) async {
    try {
      String url = "${ApiEndPoint.BASE_URL}$endPoint";
      print("URL $endPoint >> $url");
      print("PUT $endPoint >> $body");
      if (await networkCheck.hasNetwork()) {
        String token = await Prefs.read(Prefs.TOKEN) ?? "";
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'authorization': "Bearer $token",
        };
        print("headers : $headers");
        print("token : $token");
        Options options = Options(headers: headers);
        var response = await dio.put(
          url,
          options: options,
          data: body,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
          queryParameters: queryParameters,
        ).timeout(duration);
        return response;
      } else {
        log("no internet issue");
        networkCheck.noInternetConnectionDialog();
      }
    } catch (e) {
      if (e is DioException) {
        if(e.type == DioExceptionType.cancel){
          return Response(data: {
            "status" : cancelTokenStatusCode,
          }, requestOptions: RequestOptions());
        }
        throw DioExceptions.fromDioError(dioError: e);
      } else {
        throw Exception("Error");
      }
    }
  }

  getApi(
      {required String endPoint,
        Object? body,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
        bool isCancelToken = false,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headersParm}) async {
    try {
      String url = "${ApiEndPoint.BASE_URL}$endPoint";
      // print("URL $endPoint >> $url");
      // print("GET $endPoint >> $queryParameters");
      if (await networkCheck.hasNetwork()) {
        if (isCancelToken) {
          cancelToken.cancel();

          if (cancelToken.isCancelled) {
            cancelToken = CancelToken();
          }
        }
        String time = DateTime.now().microsecondsSinceEpoch.toString();
        print('Milisecond of time is $time');
        String token = await Prefs.read(Prefs.TOKEN) ?? "";
        // Map<String, String> headers = {
        //   'Content-Type': 'application/json',
        //   't': time,
        //   'sign_method': "HMAC-SHA256",
        //   'lang':'en',
        //   'client_id': "nvp75fhgqfm3mr77q8y9",
        //   'secret': "akes7qfeknv9thkqa7h74svp75tpsm8e",
        //   'sign': "akes7qfeknv9thkqa7h74svp75tpsm8e",
        //   'mode': "cors",
        // };
        Map<String, String> headers = Map();

        String t = DateTime.now().millisecondsSinceEpoch.toString();
        headers['client_id'] = "ahx3majss889rgk5n9pq";
        // headers['t'] = "1697789534745";
        headers['t'] = t;
        headers['sign_method'] = 'HMAC-SHA256';
        headers['sign'] = gernateSignKey(t);
        // headers['sign'] = "002F1551F045EDF0BE9947A66260DCE8BCB2FCA7E6AB4BE43ADBB4DDDF853A05";
        print('sign ${headers['sign']}');
        Options options = Options(headers: headersParm ?? headers);
        // print("headers : $headers");
        Response response = await dio.get(
          url,
          options: options,
          data: body,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
          queryParameters: queryParameters,
        ).timeout(duration);
        return response;
      } else {
        log("no internet issue");
        networkCheck.noInternetConnectionDialog();
      }
    } catch (e) {
      if (e is DioException) {

        if(e.type == DioExceptionType.cancel){
          return Response(data: {
            "status" : cancelTokenStatusCode,
          }, requestOptions: RequestOptions());
        }
        throw DioExceptions.fromDioError(dioError: e);
      } else {
        throw Exception("Error");
      }
    }
  }



  static  String gernateSignKey(String time){
    var str='ahx3majss889rgk5n9pq${time}GET\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\n\n/v1.0/token?grant_type=1';
print('myStr:$str:');
    String signKey=calculateHMACSHA256(str,'32c3d2e014374a67a3634a0cab616f50').toUpperCase();
    print('ClientKey->-ahx3majss889rgk5n9pq-\ncurrentTime-$time-\nstr-$str-signKey-$signKey-');
    return signKey;
  }
  static String calculateHMACSHA256(String input, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(input);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  multiPart(
      {required String endPoint,
        Object? body,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
        CancelToken? cancelToken,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headersParm}) async {
    try {
      String url = "${ApiEndPoint.BASE_URL}$endPoint";
      print("URL $endPoint >> $url");

      if (await networkCheck.hasNetwork()) {
        String token = await Prefs.read(Prefs.TOKEN) ?? "";
        Map<String, String> headers = {
          'accept': 'application/json',
          'Content-Type': 'multipart/form-data',
          'authorization': "Bearer $token",
        };

        headers.addAll(headersParm ?? {});

        Options options = Options(headers: headers);

        var response = await dio.post(
          url,
          options: options,
          data: body,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
          queryParameters: queryParameters,
        ).timeout(duration);
        return response;
      } else {
        log("no internet issue");
        networkCheck.noInternetConnectionDialog();
      }
    } catch (e) {
      print("eeeeee$e");
      if (e is DioException) {
        if(e.type == DioExceptionType.cancel){
          return Response(data: {
            "status" : cancelTokenStatusCode,
          }, requestOptions: RequestOptions());
        }
        throw DioExceptions.fromDioError(dioError: e);
      } else {
        throw Exception("Error");
      }
    }
  }

  getGoogleAddressApi(
      {required String endPoint,
        Object? body,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
        CancelToken? cancelToken,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headersParm}) async {
    try {
      String url = endPoint;

      if (await networkCheck.hasNetwork()) {
        Response response = await dio.get(
          url,
        );
        return response;
      } else {
        log("no internet issue");
        networkCheck.noInternetConnectionDialog();
      }
    } catch (e) {
      if (e is DioException) {
        if(e.type == DioExceptionType.cancel){
          return Response(data: {
            "status" : cancelTokenStatusCode,
          }, requestOptions: RequestOptions());
        }
        throw DioExceptions.fromDioError(dioError: e);
      } else {
        throw Exception("Error");
      }
    }
  }


  Future<bool> cancelRequests() async {
    cancelToken.cancel();
    return cancelToken.isCancelled;
  }
}
