import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:3003';

  // Get featured artisans
  static Future<List<dynamic>> getArtisans() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/artisans'));
      
      if (response.statusCode == 200) {
        final List<dynamic> artisans = json.decode(response.body);
        print('✅ Loaded ${artisans.length} artisans');
        return artisans;
      } else {
        throw Exception('Failed to load artisans: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading artisans: $e');
      rethrow;
    }
  }

  // Get top contributors
  static Future<List<dynamic>> getContributors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/contributors'));
      
      if (response.statusCode == 200) {
        final List<dynamic> contributors = json.decode(response.body);
        print('✅ Loaded ${contributors.length} contributors');
        return contributors;
      } else {
        throw Exception('Failed to load contributors: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading contributors: $e');
      rethrow;
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
        // Return empty profile if user not found
        return {
          'user_type': 'member',
          'specialty': '',
          'bio': '',
          'total_donations': 0,
          'total_products': 0,
          'donation_count': 0,
          'available_gems': 0,
          'profile_image_url': ''
        };
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      // Return default profile on error
      return {
        'user_type': 'member',
        'specialty': '',
        'bio': '',
        'total_donations': 0,
        'total_products': 0,
        'donation_count': 0,
        'available_gems': 0,
        'profile_image_url': ''
      };
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
        return [];
      }
    } catch (e) {
      print('Error fetching user donations: $e');
      return [];
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
        return [];
      }
    } catch (e) {
      print('Error fetching user products: $e');
      return [];
    }
  }

  // 🔧 FIXED: Upload profile picture with authentication
  static Future<String?> uploadProfilePicture(int userId, File imageFile) async {
    try {
      print('📸 Starting profile picture upload for user $userId');
      
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        print('❌ No authentication token found');
        throw Exception('Authentication required. Please log in again.');
      }
      
      print('✅ Token found, reading image file...');
      
      // Read the image file and convert to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String imageData = 'data:image/jpeg;base64,$base64Image';
      
      print('✅ Image converted to base64 (${imageBytes.length} bytes)');
      print('📤 Sending upload request...');

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/$userId/profile-picture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Added authentication header
        },
        body: json.encode({'image_data_base64': imageData}),
      );

      print('📥 Server response status: ${response.statusCode}');
      print('📥 Server response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final imageUrl = responseData['profile_image_url'];
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Save to SharedPreferences
          await prefs.setString('profilePicture', imageUrl);
          await prefs.setString('profile_picture', imageUrl);
          
          print('✅ Profile picture uploaded successfully: $imageUrl');
          return imageUrl;
        } else {
          print('❌ No image URL in response');
          return null;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Authentication failed: ${response.statusCode}');
        throw Exception('Authentication failed. Please log in again.');
      } else {
        print('❌ Profile picture upload failed: ${response.statusCode}');
        print('❌ Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Profile picture upload error: $e');
      rethrow;
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
      print('📝 Updating profile for user $userId');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in again.');
      }
      
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
      
      print('📥 Update profile response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Update SharedPreferences
        if (bio.isNotEmpty) {
          await prefs.setString('userBio', bio);
          await prefs.setString('user_bio', bio);
        }
        if (name.isNotEmpty) {
          await prefs.setString('userName', name);
          await prefs.setString('user_name', name);
        }
        
        print('✅ Profile updated successfully');
        return responseData;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  // Get user impact
  static Future<Map<String, dynamic>> getUserImpact(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users/$userId/impact'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user impact: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading user impact: $e');
      return {
        'pieces_donated': '0',
        'upcycled_items': '0', 
        'gems_earned': '0'
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users/$userId/profile'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
      rethrow;
    }
  }

  static Future<void> debugEndpoints() async {
    try {
      print('🧪 Testing all endpoints...');
      
      // Test artisans endpoint
      final artisansResponse = await http.get(Uri.parse('$baseUrl/api/debug/artisans'));
      print('🎨 Debug artisans: ${artisansResponse.body}');
      
      // Test contributors endpoint  
      final contributorsResponse = await http.get(Uri.parse('$baseUrl/api/debug/contributors'));
      print('👥 Debug contributors: ${contributorsResponse.body}');
      
      // Test impact endpoint (use user ID 1 for testing)
      final impactResponse = await http.get(Uri.parse('$baseUrl/api/users/1/impact'));
      print('📊 Debug impact: ${impactResponse.body}');
      
    } catch (e) {
      print('❌ Debug endpoint test failed: $e');
    }
  }

  // Claim daily reward
  static Future<Map<String, dynamic>> claimDailyReward(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/daily-login-reward'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to claim daily reward: ${response.body}');
      }
    } catch (e) {
      print('❌ Claim daily reward error: $e');
      rethrow;
    }
  }
}