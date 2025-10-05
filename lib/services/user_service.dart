import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:3003';

  // Get featured artisans
  static Future<List<dynamic>> getArtisans() async {
    try {
      print('🔍 Fetching artisans from: $baseUrl/api/artisans');
      final response = await http.get(Uri.parse('$baseUrl/api/artisans'));
      
      print('📡 Artisans response status: ${response.statusCode}');
      print('📡 Artisans response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Found ${data.length} artisans');
        return data;
      } else {
        throw Exception('Failed to load artisans - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching artisans: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get top contributors
  static Future<List<dynamic>> getContributors() async {
    try {
      print('🔍 Fetching contributors from: $baseUrl/api/contributors');
      final response = await http.get(Uri.parse('$baseUrl/api/contributors'));
      
      print('📡 Contributors response status: ${response.statusCode}');
      print('📡 Contributors response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Found ${data.length} contributors');
        return data;
      } else {
        throw Exception('Failed to load contributors - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching contributors: $e');
      throw Exception('Network error: $e');
    }
  }

   static Future<Map<String, dynamic>> getOtherUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/profile'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      throw e;
    }
  }

  static Future<List<dynamic>> getDonationsByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/donations'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user donations');
      }
    } catch (e) {
      print('Error fetching user donations: $e');
      throw e;
    }
  }

  static Future<List<dynamic>> getProductsByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/products'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user products');
      }
    } catch (e) {
      print('Error fetching user products: $e');
      throw e;
    }
  }

  // Upload profile picture
  static Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/api/users/$userId/profile-picture')
      );
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture', 
          imageFile.path
        )
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      
      if (response.statusCode == 200 && jsonResponse['success']) {
        return jsonResponse['profile_image_url'];
      } else {
        throw Exception(jsonResponse['error'] ?? 'Upload failed');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw Exception('Profile picture upload failed: $e');
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(
    String userId, 
    String name, 
    String specialty, 
    String bio, 
    String userType
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'specialty': specialty,
          'bio': bio,
          'user_type': userType,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}