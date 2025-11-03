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
  final String? phone;
  final int availableGems;
  final int totalDonations;
  final int totalProducts;

  User({
    this.id,
    required this.name,
    required this.email,
    this.username,
    this.profileImageUrl,
    this.specialty,
    this.bio,
    this.userType,
    this.phone,
    this.availableGems = 0,
    this.totalDonations = 0,
    this.totalProducts = 0,
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
      phone: json['phone'],
      availableGems: json['available_gems'] ?? 0,
      totalDonations: json['total_donations'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
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
      'phone': phone,
      'available_gems': availableGems,
      'total_donations': totalDonations,
      'total_products': totalProducts,
    };
  }

  // Create a copy with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? username,
    String? profileImageUrl,
    String? specialty,
    String? bio,
    String? userType,
    String? phone,
    int? availableGems,
    int? totalDonations,
    int? totalProducts,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      specialty: specialty ?? this.specialty,
      bio: bio ?? this.bio,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      availableGems: availableGems ?? this.availableGems,
      totalDonations: totalDonations ?? this.totalDonations,
      totalProducts: totalProducts ?? this.totalProducts,
    );
  }
}

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null && _user!.id != null;
  bool get isInitialized => _isInitialized;
  String? get token => _token;

  AuthProvider() {
    print(' AuthProvider constructor called');
  }

  /// Initialize auth state from storage and server
  Future<void> initialize() async {
    if (_isInitialized) {
      print(' AuthProvider already initialized, skipping');
      return;
    }

    print(' Initializing AuthProvider...');
    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Load from storage
      await _loadFromStorage();

      // Step 2: If we have a token, refresh from server
      if (_token != null && _user?.id != null) {
        await _refreshFromServer();
      }

      _isInitialized = true;
      print(' AuthProvider initialized successfully');
      print('   User: ${_user?.name}');
      print('   Gems: ${_user?.availableGems}');
    } catch (e) {
      print(' Error initializing AuthProvider: $e');
      _error = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUser(User user, String token) async {
  print('🔐 Setting user directly: ${user.name}');
  
  _user = user;
  _token = token;
  _isInitialized = true;
  
  // Save to storage
  await _saveToStorage();
  
  // Refresh from server to get latest data
  await _refreshFromServer();
  
  notifyListeners();
  
  print('✅ User set: ${_user?.name} (${_user?.availableGems} gems)');
}

  /// Load auth data from SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print(' Loading from storage...');
      print('   Keys: ${prefs.getKeys()}');

      // Clean approach: Only use 'token' and 'user_data'
      _token = prefs.getString('token');
      final userDataString = prefs.getString('user_data');

      if (_token != null && userDataString != null) {
        final userData = json.decode(userDataString);
        _user = User.fromJson(userData);
        print('Loaded from storage: ${_user?.name} (${_user?.availableGems} gems)');
      } else {
        print('ℹ️ No stored auth found');
        _user = null;
        _token = null;
      }
    } catch (e) {
      print('Error loading from storage: $e');
      _user = null;
      _token = null;
    }
  }

  /// Refresh user data from server
  Future<void> _refreshFromServer() async {
    if (_user?.id == null || _token == null) return;

    try {
      print('Refreshing user data from server...');
      
      final response = await http.get(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/${_user!.id}/profile'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = User.fromJson(data);
        
        // Save updated data
        await _saveToStorage();
        
        print('User data refreshed: ${_user?.name} (${_user?.availableGems} gems)');
      } else {
        print('Failed to refresh: ${response.statusCode}');
      }
    } catch (e) {
      print('Error refreshing from server: $e');
      // Don't clear user data on refresh failure - keep cached version
    }
  }

  /// Save auth data to SharedPreferences
  Future<void> _saveToStorage() async {
    if (_user == null || _token == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save only essential keys
      await prefs.setString('token', _token!);
      await prefs.setString('user_data', json.encode(_user!.toJson()));
      
      // Legacy keys for backward compatibility (can remove later)
      await prefs.setString('userId', _user!.id.toString());
      await prefs.setString('userName', _user!.name);
      await prefs.setString('userEmail', _user!.email);
      
      print('Auth data saved to storage');
    } catch (e) {
      print('Error saving to storage: $e');
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting login: $email');
      
      final response = await http.post(
        Uri.parse('https://junk-and-gems-api.onrender.com/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _token = data['token'];
        _user = User.fromJson(data['user']);

        await _saveToStorage();
        
        // Refresh to get latest gems/stats
        await _refreshFromServer();

        _isInitialized = true;
        _isLoading = false;
        notifyListeners();

        print('Login successful: ${_user?.name}');
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Signup
  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting signup: $email');
      
      final response = await http.post(
        Uri.parse('https://junk-and-gems-api.onrender.com/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _token = data['token'];
        _user = User.fromJson(data['user']);

        await _saveToStorage();

        _isInitialized = true;
        _isLoading = false;
        notifyListeners();

        print('Signup successful: ${_user?.name}');
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Signup failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Signup failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    print('🚪 Logging out: ${_user?.name}');
    
    _user = null;
    _token = null;
    _error = null;
    _isInitialized = false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Logout complete');
    } catch (e) {
      print('Error clearing storage: $e');
    }
    
    notifyListeners();
  }

  /// Update user gems (after purchase/claim)
  Future<void> updateGems(int newGems) async {
    if (_user != null) {
      _user = _user!.copyWith(availableGems: newGems);
      await _saveToStorage();
      notifyListeners();
      print('💎 Gems updated: $newGems');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? bio,
    String? profileImageUrl,
    String? phone,
    String? email,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        bio: bio,
        profileImageUrl: profileImageUrl,
        phone: phone,
        email: email,
      );
      await _saveToStorage();
      notifyListeners();
      print('Profile updated');
    }
  }

  /// Manually refresh user data (pull-to-refresh)
  Future<void> refresh() async {
    await _refreshFromServer();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}