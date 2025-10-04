// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3003'; 

  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (responseBody.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return {'success': true};
      } else {
        throw Exception('Request failed with status: $statusCode');
      }
    }

    final dynamic jsonResponse = json.decode(responseBody);

    if (statusCode >= 200 && statusCode < 300) {
      return jsonResponse;
    } else {
      final errorMessage = jsonResponse['error'] ?? 'Request failed with status: $statusCode';
      throw Exception(errorMessage);
    }
  }

  // Helper method to save token after login/signup
  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Helper method to remove token on logout
  static Future<void> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Helper method to get token
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}