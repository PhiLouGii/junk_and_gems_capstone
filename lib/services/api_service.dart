import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3003';

  // Store authentication token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      print('✅ Token saved successfully');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  // Retrieve authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('🔐 Token retrieved: ${token != null ? "EXISTS" : "NULL"}');
      return token;
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  // Remove token (logout)
  static Future<void> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      print('✅ Token removed successfully');
    } catch (e) {
      print('❌ Error removing token: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      print('🔍 isLoggedIn check: $isLoggedIn (token: ${token != null ? "exists" : "null"})');
      return isLoggedIn;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      print('✅ User ID saved: $userId');
    } catch (e) {
      print('❌ Error saving user ID: $e');
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      print('👤 User ID retrieved: ${userId ?? "NULL"}');
      return userId;
    } catch (e) {
      print('❌ Error retrieving user ID: $e');
      return null;
    }
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(userData));
      print('✅ User data saved');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        return json.decode(userDataString);
      }
      return null;
    } catch (e) {
      print('❌ Error retrieving user data: $e');
      return null;
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Save token
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        // Save user ID
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id'].toString());
        }
        
        // Save user data
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
        
        print('✅ Login successful - Token and user data saved');
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      print('📝 Attempting signup for: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      print('📡 Signup response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Save token
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        // Save user ID
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id'].toString());
        }
        
        // Save user data
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
        
        print('✅ Signup successful - Token and user data saved');
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      print('❌ Signup error: $e');
      throw Exception('Signup failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('userData');
      print('✅ Logout successful - All data cleared');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  // Test connection
  static Future<void> testConnection() async {
    try {
      print('🔌 Testing server connection...');
      final response = await http.get(Uri.parse('$baseUrl/materials'));
      if (response.statusCode == 200) {
        print('✅ Server connection successful');
      } else {
        print('⚠️ Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Server connection failed: $e');
      throw Exception('Cannot connect to server');
    }
  }

  // Verify token is valid
  static Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('❌ No token found');
        return false;
      }

      // Try to make an authenticated request
      final response = await http.get(
        Uri.parse('$baseUrl/materials'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Token is invalid or expired');
        await removeToken();
        return false;
      }

      print('✅ Token is valid');
      return true;
    } catch (e) {
      print('❌ Token verification error: $e');
      return false;
    }
  }

  // Debug: Print all stored authentication data
  static Future<void> debugAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');
      final userData = prefs.getString('userData');
      
      print('🐛 DEBUG AUTH DATA:');
      print('Token: ${token != null ? "EXISTS (${token.substring(0, 20)}...)" : "NULL"}');
      print('User ID: ${userId ?? "NULL"}');
      print('User Data: ${userData ?? "NULL"}');
    } catch (e) {
      print('❌ Debug auth data error: $e');
    }
  }
}