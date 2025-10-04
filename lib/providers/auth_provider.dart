// providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int? id;
  final String name;
  final String email;
  final String? username;
  final String? profileImageUrl;
  final String? specialty;
  final String? bio;
  final String? userType;
  final int availableGems;

  User({
    this.id,
    required this.name,
    required this.email,
    this.username,
    this.profileImageUrl,
    this.specialty,
    this.bio,
    this.userType,
    this.availableGems = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      profileImageUrl: json['profile_image_url'],
      specialty: json['specialty'],
      bio: json['bio'],
      userType: json['user_type'],
      availableGems: json['available_gems'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'profile_image_url': profileImageUrl,
      'specialty': specialty,
      'bio': bio,
      'user_type': userType,
      'available_gems': availableGems,
    };
  }
}

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final String? userData = prefs.getString('user_data');

    if (token != null && userData != null) {
      _token = token;
      _user = User.fromJson(json.decode(userData));
      notifyListeners();
    }
  }

  // For testing - you can remove this later
  void setTestUser() {
    _user = User(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      availableGems: 840,
    );
    _token = 'test_token';
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call - replace with your actual login logic
      await Future.delayed(Duration(seconds: 2));
      
      _user = User(
        id: 1,
        name: 'Test User',
        email: email,
        availableGems: 840,
      );
      _token = 'dummy_token';

      // Store auth data
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', json.encode(_user!.toJson()));

    } catch (error) {
      _error = 'Login failed: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;

    // Clear stored auth data
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}