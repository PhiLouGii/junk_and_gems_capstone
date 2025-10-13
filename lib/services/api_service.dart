import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3003';

  static Future<Map<String, String>> _getHeaders() async {
    final String? token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (error) {
      print('❌ API GET error: $error');
      throw Exception('Network error: $error');
    }
  }

  static Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (error) {
      print('❌ API POST error: $error');
      throw Exception('Network error: $error');
    }
  }

  static Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (error) {
      print('❌ API PUT error: $error');
      throw Exception('Network error: $error');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (error) {
      print('❌ API DELETE error: $error');
      throw Exception('Network error: $error');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    print('📡 API Response: $statusCode - ${response.request?.url}');

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
    } else if (statusCode == 401 || statusCode == 403) {
      // Authentication error - clear token
      removeToken();
      final errorMessage = jsonResponse['error'] ?? 'Authentication failed';
      throw Exception('$errorMessage. Please login again.');
    } else {
      final errorMessage = jsonResponse['error'] ?? 'Request failed with status: $statusCode';
      throw Exception(errorMessage);
    }
  }

  // Helper method to save token after login/signup
  static Future<void> saveToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('💾 Token saved successfully');
    } catch (e) {
      print('❌ Error saving token: $e');
      throw Exception('Failed to save authentication token');
    }
  }

  // Helper method to remove token on logout
  static Future<void> removeToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      print('🗑️ Token removed');
    } catch (e) {
      print('❌ Error removing token: $e');
    }
  }

  // Helper method to get token
  static Future<String?> getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('🔐 Token retrieved: ${token != null ? "Present" : "NULL"}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Test server connection
  static Future<void> testConnection() async {
    try {
      print('🔌 Testing connection to server...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/debug/tables'),
      ).timeout(const Duration(seconds: 5));

      print('✅ Server is reachable, status: ${response.statusCode}');
      print('📋 Response: ${response.body}');
    } catch (e) {
      print('❌ Cannot reach server: $e');
      throw Exception('Cannot connect to server. Please check your connection.');
    }
  }
}