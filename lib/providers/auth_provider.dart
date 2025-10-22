import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    print('AuthProvider constructor called');
  }

  // Call this method to initialize the provider
  Future<void> initialize() async {
    if (_isInitialized) {
      print('AuthProvider already initialized');
      return;
    }

    print('Initializing AuthProvider...');
    await _loadStoredAuth();
    
    _isInitialized = true;
    
    if (_user != null) {
      print('Loaded user: ${_user?.name} (ID: ${_user?.id})');
    } else {
      print('ℹ️ No user logged in - user needs to login');
    }
    
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
        print('Loaded stored user: ${_user?.name} (ID: ${_user?.id})');
      } else {
        print('ℹ️ No stored auth found');
      }
    } catch (e) {
      print('Error loading stored auth: $e');
    }
  }

  // REAL login that connects to the API
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting login for: $email');
      
      final response = await http.post(
        Uri.parse('https://junk-and-gems-api.onrender.com/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _token = data['token'];
        _user = User.fromJson(data['user']);

        print('   Login successful!');
        print('   User ID: ${_user?.id}');
        print('   User Name: ${_user?.name}');
        print('   User Email: ${_user?.email}');

        // Store auth data
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', json.encode(_user!.toJson()));
        
        // Also store individual fields for backwards compatibility
        await prefs.setString('userId', _user!.id.toString());
        await prefs.setString('token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Login failed';
        print('Login failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _error = 'Login failed: $error';
      print('Login error: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // REAL signup that connects to your API
  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting signup for: $email');
      
      final response = await http.post(
        Uri.parse('https://junk-and-gems-api.onrender.com/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      print('Signup response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _token = data['token'];
        _user = User.fromJson(data['user']);

        print('   Signup successful!');
        print('   User ID: ${_user?.id}');
        print('   User Name: ${_user?.name}');
        print('   User Email: ${_user?.email}');

        // Store auth data
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', json.encode(_user!.toJson()));
        
        // Also store individual fields for backwards compatibility
        await prefs.setString('userId', _user!.id.toString());
        await prefs.setString('token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Signup failed';
        print('Signup failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _error = 'Signup failed: $error';
      print('Signup error: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    print('Logging out user: ${_user?.name}');
    
    _user = null;
    _token = null;
    _error = null;

    // Clear stored auth data
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('userId');
    await prefs.remove('token');

    print('Logout complete');
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
      
      // Update stored user data
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('user_data', json.encode(_user!.toJson()));
      });
      
      notifyListeners();
    }
  }

  // Refresh user data from server
  Future<void> refreshUserData() async {
    if (_user?.id == null || _token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/${_user!.id}/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _user = User.fromJson(userData);
        
        // Update stored data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(_user!.toJson()));
        
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }
}