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

  // Check if user is logged in - UPDATED
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');
      
      final isLoggedIn = token != null && token.isNotEmpty && 
                        userId != null && userId.isNotEmpty;
      
      print('🔍 isLoggedIn check: $isLoggedIn');
      print('  - Has token: ${token != null}');
      print('  - Has userId: ${userId != null}');
      
      return isLoggedIn;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // Save user ID - UPDATED
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

  // Save user data - UPDATED
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save individual fields for easy access
      if (userData['id'] != null) {
        await prefs.setString('userId', userData['id'].toString());
      }
      if (userData['name'] != null) {
        await prefs.setString('userName', userData['name']);
      }
      if (userData['email'] != null) {
        await prefs.setString('userEmail', userData['email']);
      }
      if (userData['username'] != null) {
        await prefs.setString('username', userData['username']);
      } else if (userData['email'] != null) {
        // Generate username from email if not provided
        final email = userData['email'] as String;
        await prefs.setString('username', email.split('@')[0]);
      }
      
      // Also save the complete user data as JSON
      await prefs.setString('userData', json.encode(userData));
      
      print('✅ User data saved completely');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  // Get user data - UPDATED
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

  // Get current user info - NEW METHOD
  static Future<Map<String, String?>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'id': prefs.getString('userId'),
        'name': prefs.getString('userName'),
        'email': prefs.getString('userEmail'),
        'username': prefs.getString('username'),
      };
    } catch (e) {
      print('❌ Get current user error: $e');
      return {};
    }
  }

  // Login - UPDATED
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
      print('📡 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Save token
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        // Save user data using the updated method
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
        
        print('✅ Login successful - Token and user data saved');
        
        // Debug: print what we saved
        await debugAuthData();
        
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

  // Signup - UPDATED
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
        
        // Save user data using the updated method
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
        
        print('✅ Signup successful - Token and user data saved');
        
        // Debug: print what we saved
        await debugAuthData();
        
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

  // Logout - UPDATED
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all data
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

  // Debug: Print all stored authentication data - UPDATED
  static Future<void> debugAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('=' * 60);
      print('🔍 DEBUG: SHARED PREFERENCES AUTH DATA');
      print('=' * 60);
      print('All keys: ${prefs.getKeys()}');
      print('-' * 60);
      
      final token = prefs.getString('token');
      print('Token: ${token != null ? "EXISTS (${token.substring(0, min(20, token.length))}...)" : "NULL"}');
      print('User ID: ${prefs.getString('userId') ?? "NULL"}');
      print('User Name: ${prefs.getString('userName') ?? "NULL"}');
      print('User Email: ${prefs.getString('userEmail') ?? "NULL"}');
      print('Username: ${prefs.getString('username') ?? "NULL"}');
      
      final userDataString = prefs.getString('userData');
      print('User Data (JSON): ${userDataString != null ? "EXISTS" : "NULL"}');
      
      print('=' * 60);
    } catch (e) {
      print('❌ Debug auth data error: $e');
    }
  }

  // Helper function for substring safety
  static int min(int a, int b) => a < b ? a : b;
}