// import 'package:crypto/crypto.dart';
// import 'package:convert/convert.dart';
// import 'dart:convert';
//
// class Testing{
//   int getTime() {
//     var timestamp = DateTime.now().millisecondsSinceEpoch;
//     return timestamp;
//   }
//
//   String calculateSignature() {
//     var timestamp = getTime();
//     pm.environment['timestamp'] = timestamp;
//
//     String clientId = pm.environment['client_id'];
//     String secret = pm.environment['secret'];
//
//     var accessToken = "";
//     if (pm.environment.containsKey('easy_access_token')) {
//       accessToken = pm.environment['easy_access_token'];
//     }
//
//     String httpMethod = 'GET';
//     String query = pm.request.url.query;
//     String mode = pm.request.body.mode;
//     Map<String, String> headers = pm.request.headers;
//
//     // SHA256
//     var signMap = stringToSign(query, mode, httpMethod, secret);
//     var urlStr = signMap['url'];
//     var signStr = signMap['signUrl'];
//     pm.request.url = pm.request.url.host + urlStr;
//     var nonce = '';
//     if (headers.containsKey('nonce')) {
//       var jsonHeaders = Map<String, String>.from(headers);
//       jsonHeaders.forEach((key, value) {
//         if (key == 'nonce' && !value.isEmpty) {
//           nonce = headers['nonce'];
//         }
//       });
//     }
//     var sign = calcSign(clientId, timestamp, nonce, signStr, secret);
//     pm.environment['easy_sign'] = sign;
//     return sign;
//   }
//
//   String calcSign(String clientId, int timestamp, String nonce, String signStr, String secret) {
//     var str = '$clientId$timestamp$nonce$signStr';
//     var bytes = utf8.encode(str);
//     var hmacSha256 = Hmac(sha256, utf8.encode(secret));
//     var digest = hmacSha256.convert(bytes);
//     return HEX.encode(digest.bytes).toUpperCase();
//   }
//
//   Map<String, String> stringToSign(String query, String mode, String method, String secret) {
//     var sha256 = '';
//     var url = '';
//     var headersStr = '';
//     Map<String, String> headers = pm.request.headers;
//     var map = {};
//     var arr = <String>[];
//     var bodyStr = '';
//
//     if (query != null && query.isNotEmpty) {
//       toJsonObj(query, arr, map);
//     }
//
//     if (pm.request.body != null && mode != null) {
//       if (mode != 'formdata' && mode != 'urlencoded') {
//         bodyStr = replacePostmanParams(pm.request.body.toString());
//       } else if (mode == 'formdata') {
//         toJsonObj(pm.request.body['formdata'], arr, map);
//       } else if (mode == 'urlencoded') {
//         toJsonObj(pm.request.body['urlencoded'], arr, map);
//       }
//     }
//
//     sha256 = Sha256Util.encryption(bodyStr);
//     arr.sort();
//     arr.forEach((item) {
//       url += '$item=${map[item]}&';
//     });
//
//     if (url.isNotEmpty) {
//       url = url.substring(0, url.length - 1);
//       url = '/${pm.request.url.path.join('/')}?$url';
//     } else {
//       url = '/${pm.request.url.path.join('/')}';
//     }
//
//     if (headers.containsKey('Signature-Headers') && headers['Signature-Headers'].isNotEmpty) {
//       var jsonHeaders = Map<String, String>.from(headers);
//       var signHeaderStr = headers['Signature-Headers'];
//       var signHeaderKeys = signHeaderStr.split(':');
//       signHeaderKeys.forEach((item) {
//         var val = '';
//         if (isSelected(jsonHeaders, item) && headers[item] != null) {
//           val = headers[item];
//         }
//         headersStr += '$item:$val\n';
//       });
//     }
//
//     var signMap = <String, String>{
//       'signUrl': '$method\n$sha256\n$headersStr\n$url',
//       'url': url,
//     };
//
//     return signMap;
//   }
//
//   bool isSelected(Map<String, String> jsonHeaders, String key) {
//     var result = true;
//     jsonHeaders.forEach((itemKey, itemValue) {
//       if (itemKey == key && itemValue.isEmpty) {
//         result = false;
//       }
//     });
//     return result;
//   }
//
//   String replacePostmanParams(String str) {
//     while (str.contains('{{') && str.contains('}}')) {
//       var key = str.substring(str.indexOf('{{') + 2, str.indexOf('}}'));
//       var value = pm.environment[key] ?? '';
//       str = str.replace('{{$key}}', value);
//     }
//     return str;
//   }
//
//   String replacePostmanUrl(String str) {
//     while (str.contains('{{') && str.contains('}}')) {
//       var key = str.substring(str.indexOf('{{') + 2, str.indexOf('}}'));
//       var value = pm.environment[key] ?? '';
//       str = str.replace('{{$key}}', value);
//     }
//
//     while (str.contains(':')) {
//       var tempStr = str.substring(str.indexOf(':') + 1);
//       var key = '';
//       if (tempStr.contains('/')) {
//         key = tempStr.substring(0, tempStr.indexOf('/'));
//       } else if (tempStr.contains('?')) {
//         key = tempStr.substring(0, tempStr.indexOf('?'));
//       } else {
//         key = tempStr;
//       }
//       var value = pm.request.url.variables[key] ?? '';
//       str = str.replace(':$key', value);
//     }
//
//     return str;
//   }
//
// }