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
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null && _user!.id != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    print('🔧 AuthProvider constructor called');
    // Don't call async methods in constructor
  }

  // Call this method to initialize the provider
  Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ AuthProvider already initialized');
      return;
    }

    print('🔧 Initializing AuthProvider...');
    await _loadStoredAuth();
    
    // Auto-login test user for development if no user exists
    if (_user == null) {
      print('👤 No stored user found, creating test user...');
      await setTestUser();
    } else {
      print('✅ Loaded stored user: ${_user?.name} (ID: ${_user?.id})');
    }
    
    _isInitialized = true;
    print('✅ AuthProvider initialization complete');
    print('📊 Final state - User: ${_user?.name}, ID: ${_user?.id}, Authenticated: $isAuthenticated');
    notifyListeners();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String? userData = prefs.getString('user_data');

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(json.decode(userData));
        print('✅ Loaded stored user: ${_user?.name} (ID: ${_user?.id})');
      } else {
        print('ℹ️ No stored auth found');
      }
    } catch (e) {
      print('⚠️ Error loading stored auth: $e');
    }
  }

  // For testing - you can remove this later
  Future<void> setTestUser() async {
    print('👤 Creating test user...');
    
    _user = User(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      username: 'testuser',
      availableGems: 840,
      userType: 'contributor',
    );
    _token = 'test_token_123';
    
    // Store test user
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', json.encode(_user!.toJson()));
      print('✅ Test user stored in preferences');
    } catch (e) {
      print('⚠️ Error storing test user: $e');
    }
    
    print('✅ Test user created: ${_user?.name} (ID: ${_user?.id})');
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

  // Method to update user gems after claiming
  void updateUserGems(int newGems) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        username: _user!.username,
        profileImageUrl: _user!.profileImageUrl,
        specialty: _user!.specialty,
        bio: _user!.bio,
        userType: _user!.userType,
        availableGems: newGems,
      );
      notifyListeners();
    }
  }
}