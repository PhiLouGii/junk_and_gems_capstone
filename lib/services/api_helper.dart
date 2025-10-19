import 'dart:async';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const int timeoutSeconds = 90;
  
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return http.get(url, headers: headers).timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () {
        throw TimeoutException('Server is waking up. Please try again in a moment.');
      },
    );
  }
  
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) {
    return http.post(url, headers: headers, body: body).timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () {
        throw TimeoutException('Server is waking up. Please try again in a moment.');
      },
    );
  }
  
  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) {
    return http.put(url, headers: headers, body: body).timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () {
        throw TimeoutException('Server is waking up. Please try again in a moment.');
      },
    );
  }
  
  static Future<http.Response> delete(Uri url, {Map<String, String>? headers}) {
    return http.delete(url, headers: headers).timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () {
        throw TimeoutException('Server is waking up. Please try again in a moment.');
      },
    );
  }
}