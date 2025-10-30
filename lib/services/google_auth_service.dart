import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google and authenticate with backend
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('Google Sign-In successful:');
      print('  Name: ${googleUser.displayName}');
      print('  Email: ${googleUser.email}');
      print('  ID: ${googleUser.id}');

      // Send Google token to your backend for verification and user creation/login
      final response = await http.post(
        Uri.parse('https://junk-and-gems-api.onrender.com/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_token': googleAuth.idToken,
          'access_token': googleAuth.accessToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'google_id': googleUser.id,
        }),
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        // Store authentication data
        final prefs = await SharedPreferences.getInstance();
        
        // Clear old auth data
        await prefs.remove('auth_token');
        await prefs.remove('token');
        await prefs.remove('user_data');
        await prefs.remove('userId');
        await prefs.remove('userName');
        await prefs.remove('userEmail');
        
        final token = result['token'];
        final userData = result['user'];
        
        // Store in BOTH formats (same as regular login)
        await prefs.setString('auth_token', token);
        await prefs.setString('token', token);
        await prefs.setString('user_data', json.encode(userData));
        await prefs.setString('userId', userData['id'].toString());
        await prefs.setString('userName', userData['name']);
        await prefs.setString('userEmail', userData['email']);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGoogleUser', true); // Mark as Google user
        
        print('User data stored successfully');
        return result;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Google authentication failed');
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      
      // Clear stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      print('Google Sign-Out successful');
    } catch (e) {
      print('Google Sign-Out error: $e');
      rethrow;
    }
  }

  /// Check if user is currently signed in with Google
  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isGoogleUser') ?? false;
  }

  /// Get current Google user (if signed in)
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.signInSilently();
  }
}