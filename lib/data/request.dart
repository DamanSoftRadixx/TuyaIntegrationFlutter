  import 'dart:convert';
  import 'dart:io';
  import 'dart:typed_data';
  import 'package:dio/dio.dart';
  import 'dart:convert';
  import 'dart:typed_data';
  import 'package:crypto/crypto.dart';
  import 'package:hex/hex.dart';

  class RequestSignUtils {
    // Access ID
    // static String accessId = "nvp75fhgqfm3mr77q8y9"; // app auth
    // static String accessId = "vjsrdmnyygmfhspen543"; //app ath from cloud
      static String accessId = "ahx3majss889rgk5n9pq"; // cloud auth
    // Access Secret
    // static String accessKey = "akes7qfeknv9thkqa7h74svp75tpsm8e"; // app auth
    // static String accessKey = "c55d222b03254fe8acf2dfead52236c2"; // app auth from cloud
    static String accessKey = "32c3d2e014374a67a3634a0cab616f50"; // cloud auth
    // Tuya could endpoint
    static String endpoint = "https://openapi.tuyain.com";

    static Dio dio = Dio();

    static void initialize() {
      dio.options.baseUrl = endpoint;
    }

   static void getTokenn() async {
      print('inside get token method');
      RequestSignUtils.initialize();
      print('after initialize');

      final getTokenPath = "/v1.0/token?grant_type=1";
      final result = await RequestSignUtils.execute(getTokenPath, "GET", "",Map());

      print('Return token is ${result}');
    }

    static Future<Map<String, dynamic>> execute(
        String path, String method, String body, Map<String, String> customHeaders) async {
      try {
        if (accessId.isEmpty || accessKey.isEmpty) {
          throw Exception("Developer information is not initialized!");
        }

        String url = dio.options.baseUrl + path;

        Options options = Options(headers: await getHeader(method, body, customHeaders));
        print('options which is sending is ${options.headers.toString()}');

        Response response;

        if (method == "GET") {
          response = await dio.get(url, options: options);
          print('resonse hiting url is ${response.requestOptions.uri}');
        } else if (method == "POST") {
          response = await dio.post(url, data: body, options: options);
        } else if (method == "PUT") {
          response = await dio.put(url, data: body, options: options);
        } else if (method == "DELETE") {
          response = await dio.delete(url, data: body, options: options);
        } else {
          throw Exception("Method only supports GET, POST, PUT, DELETE");
        }

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception("Request failed with status: ${response.statusCode}");
        }
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    static Future<Map<String, String>> getHeader(
        String method, String body, Map<String, String> headerMap) async {
      Map<String, String> headers = Map();

      String t = DateTime.now().millisecondsSinceEpoch.toString();
      // headers['client_id'] = "nvp75fhgqfm3mr77q8y9";
      headers['client_id'] = accessId;
      // headers['t'] = t;
      headers['t'] = t;
      headers['sign_method'] = 'HMAC-SHA256';
      headers['lang'] = 'en';
      // headers['Signature-Headers'] = headerMap['Signature-Headers'] ?? '';

      // String nonceStr = headerMap['nonce'] ?? '';
      // headers['nonce'] = nonceStr;

      // String stringToSignn = await stringToSign(method, body, headerMap);
      // print('sign string is --${stringToSignn}--');
      String accessToken = ""; // Replace with your access token if needed
      headers['sign'] = gernateSignKey(t);
      // if (accessToken.isNotEmpty) {
      //   headers['access_token'] = accessToken;
      //   headers['sign'] = sign(accessId, accessKey, t, accessToken, "", stringToSignn).replaceAll(" ", "");
      // } else {
      //   headers['sign'] = gernateSignKey();
      // }
      //   headers['sign'] = "D76F24A16EA4FAB0C5A8AA4E1F62D30A4A37FDF58A5D402DBC8C7834F5EA4079";
      print('sign ${headers['sign']}');

      return headers;
    }
  static  String gernateSignKey(String time){
      // str = client_id + t + nonce + stringToSign
      // sign = HMAC-SHA256(str, secret).toUpperCase()
      // var str='ahx3majss889rgk5n9pq$time';
      String signKey=calculateHMACSHA256('$accessId$time',accessKey).toUpperCase();
      print('before up $signKey');

      print('ClientKey->-ahx3majss889rgk5n9pq-\ncurrentTime-$time-\nstr-$accessId-signKey-$signKey-');
      return signKey;
    }
    static String calculateHMACSHA256(String input, String secret) {
      final key = utf8.encode(secret);
      final bytes = utf8.encode(input);
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(bytes);
      return digest.toString();
    }

    static Future<String> stringToSign(
        String method, String body, Map<String, String> headers) async {
      List<String> lines = [];
      lines.add(method.toUpperCase());
      String bodyHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
      if (body.isNotEmpty) {
        bodyHash = Sha256Util.encryption(body);
      }
      String signHeaders = headers['Signature-Headers'] ?? '';
      String headerLine = '';
      if (signHeaders.isNotEmpty) {
        List<String> signHeaderNames = signHeaders.split(RegExp(r'\s*:\s*'));
        headerLine = signHeaderNames
            .map((it) => '$it:${headers[it]}')
            .where((it) => it.isNotEmpty)
            .join('\n');
      }
      lines.add(bodyHash);
      lines.add(headerLine);
      String paramSortedPath = getPathAndSortParam(dio.options.baseUrl);
      lines.add(paramSortedPath);
      return lines.join('\n');
    }

    static String sign(String accessId, String secret, String t, String accessToken,
        String nonce, String stringToSign) {
      String sb = accessId;
      if (accessToken.isNotEmpty) {
        sb += accessToken;
      }
      sb += t;
      if (nonce.isNotEmpty) {
        sb += nonce;
      }
      sb += stringToSign;
      return Sha256Util.sha256HMAC(sb, secret);
    }

    static String getPathAndSortParam(String url) {
      try {
        Uri uri = Uri.parse(url);
        String query = Uri.decodeFull(uri.query);
        String path = uri.path;
        if (query.isEmpty) {
          return path;
        }
        Map<String, String> kvMap = Map();
        List<String> kvs = query.split('&');
        for (String kv in kvs) {
          List<String> kvArr = kv.split('=');
          if (kvArr.length > 1) {
            kvMap[kvArr[0]] = kvArr[1];
          } else {
            kvMap[kvArr[0]] = '';
          }
        }
        return path +
            '?' +
            kvMap.entries.map((it) => '${it.key}=${it.value}').join('&');
      } catch (e) {
        return Uri.parse(url).path;
      }
    }
  }

  class Sha256Util {
    static String encryption(String str) {
      return encryptionBytes(Uint8List.fromList(utf8.encode(str)));
      }

    static String encryptionBytes(Uint8List buf) {
      Digest digest = sha256.convert(buf);
      return HEX.encode(digest.bytes);
    }

    static String sha256HMAC(String content, String secret) {
      List<int> keyBytes = utf8.encode(secret);
      List<int> dataBytes = utf8.encode(content);

      Hmac hmac = Hmac(sha256, keyBytes);
      Digest digest = hmac.convert(dataBytes);
      return HEX.encode(digest.bytes);
    }
  }

  class TuyaCloudSDKException implements Exception {
    int? code;
    String message;

    TuyaCloudSDKException(this.message);

    TuyaCloudSDKException.withCode(this.code, this.message);

    @override
    String toString() {
      if (code != null) {
        return "TuyaCloudSDKException: [$code] $message";
      }
      return "TuyaCloudSDKException: $message";
    }
  }
