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

  //nitialize with proper reset handling
  Future<void> initialize() async {
    print(' Initializing AuthProvider...');
    print('   Already initialized: $_isInitialized');
    print('   Current user: ${_user?.name}');
    print('   Is authenticated: $isAuthenticated');

    await _loadStoredAuth();
    
    _isInitialized = true;
    
    if (_user != null && _token != null) {
      print('Loaded user from storage: ${_user?.name} (ID: ${_user?.id})');
    } else {
      print('ℹ️ No user logged in - user needs to login');
    }
    
    notifyListeners();
  }

  // Better storage loading with comprehensive key checking
  Future<void> _loadStoredAuth() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      print(' Checking SharedPreferences...');
      print('   All keys: ${prefs.getKeys()}');
      
      // Try to load from primary storage keys
      String? token = prefs.getString('auth_token');
      String? userData = prefs.getString('user_data');

      if (token == null) {
        token = prefs.getString('token');
        print('   Using fallback token key');
      }

      print('   Token exists: ${token != null}');
      print('   User data exists: ${userData != null}');

      if (token != null && userData != null) {
        _token = token;
        final userJson = json.decode(userData);
        _user = User.fromJson(userJson);
        print('Successfully loaded stored user: ${_user?.name} (ID: ${_user?.id})');
      } else if (token != null) {
        print('Have token but no user_data, attempting to reconstruct...');
        
        int? userId;
        if (prefs.containsKey('userId')) {
          final userIdValue = prefs.get('userId');
          if (userIdValue is int) {
            userId = userIdValue;
          } else if (userIdValue is String) {
            userId = int.tryParse(userIdValue);
          }
        }
        
        final userName = prefs.getString('userName');
        final userEmail = prefs.getString('userEmail');
        
        print('   Reconstructed data:');
        print('     userId: $userId');
        print('     userName: $userName');
        print('     userEmail: $userEmail');
        
        if (userId != null && userName != null && userEmail != null) {
          _token = token;
          _user = User(
            id: userId,
            name: userName,
            email: userEmail,
          );
          
          // Save properly for next time
          await _saveAuthData();
          
          print('Successfully reconstructed user from individual fields');
        } else {
          print('Could not reconstruct user data');
          _user = null;
          _token = null;
        }
      } else {
        print('ℹ️ No stored auth found (no token or user data)');
        _user = null;
        _token = null;
      }
    } catch (e, stackTrace) {
      print('Error loading stored auth: $e');
      print('Stack trace: $stackTrace');
      _user = null;
      _token = null;
    }
  }

  // Centralized method to save auth data consistently
  Future<void> _saveAuthData() async {
    if (_user == null || _token == null) {
      print('Cannot save auth data - user or token is null');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Primary storage
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', json.encode(_user!.toJson()));
      
      // Legacy/backup storage for compatibility
      await prefs.setString('token', _token!);
      await prefs.setString('userId', _user!.id.toString());
      await prefs.setString('userName', _user!.name);
      await prefs.setString('userEmail', _user!.email);
      
      print(' Auth data saved successfully');
      print('   User ID: ${_user!.id}');
      print('   User Name: ${_user!.name}');
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  //Login with better storage
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting login for: $email');
      
      // Clear existing session first
      await logout();
      
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

        print(' Login successful!');
        print('   User ID: ${_user?.id}');
        print('   User Name: ${_user?.name}');
        print('   User Email: ${_user?.email}');

        // Use centralized save method
        await _saveAuthData();

        _isLoading = false;
        _isInitialized = true; // Mark as initialized after successful login
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Login failed';
        print(' Login failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _error = 'Login failed: $error';
      print(' Login error: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Signup with better storage
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

        print('Signup successful!');
        print('   User ID: ${_user?.id}');
        print('   User Name: ${_user?.name}');
        print('   User Email: ${_user?.email}');

        // Use centralized save method
        await _saveAuthData();

        _isLoading = false;
        _isInitialized = true;
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

  // Logout with comprehensive cleanup and proper reset
  Future<void> logout() async {
    print('Logging out user: ${_user?.name}');
    
    // Clear in-memory state FIRST
    _user = null;
    _token = null;
    _error = null;
    _isInitialized = false; 
    
    // Then clear storage
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 
      
      print('Logout complete - all auth data cleared (memory + storage)');
    } catch (e) {
      print('Error clearing SharedPreferences: $e');
    }
    
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
      _saveAuthData();
      
      notifyListeners();
    }
  }

  // Refresh user data from server
  Future<void> refreshUserData() async {
    if (_user?.id == null || _token == null) return;

    try {
      print('🔄 Refreshing user data for user ${_user!.id}...');
      
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
        await _saveAuthData();
        
        print('User data refreshed successfully');
        notifyListeners();
      } else {
        print('Failed to refresh user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }
}