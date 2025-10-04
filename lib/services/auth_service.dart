import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/services/api_service.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:3000"; 
  // 👆 Android emulator. Use "http://localhost:3000" if running Flutter web.

  // Save user data to shared preferences
  static Future<void> saveUserData(String token, String userId, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
  }
  
  // Get stored user data
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token') ?? '',
      'userId': prefs.getString('userId') ?? '',
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
    };
  }
  
  // Clear user data (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('name');
    await prefs.remove('email');
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
  
  // Sign up
  static Future<Map<String, dynamic>> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Connection failed: $e'};
    }
  }
  
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Connection failed: $e'};
    }
  }
  
  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Connection failed: $e'};
    }
  }
}