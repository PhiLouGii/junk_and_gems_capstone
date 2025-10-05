import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

class MaterialService {
  static const String _baseUrl = 'http://10.0.2.2:3003';

  static Future<bool> createMaterial(
      Map<String, dynamic> materialData, List<XFile> images) async {
    try {
      print('📸 Starting image upload to Cloudinary...');
      
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        // Upload images to Cloudinary first
        imageUrls = await CloudinaryService.uploadMultipleImages(images);
        print('✅ Image upload complete. Got ${imageUrls.length} URLs');
      } else {
        print('ℹ️ No images to upload');
      }
      
      // Prepare the final data with proper types
      final Map<String, dynamic> requestData = {
        'title': materialData['title']?.toString() ?? '',
        'description': materialData['description']?.toString() ?? '',
        'category': materialData['category']?.toString() ?? '',
        'quantity': materialData['quantity']?.toString() ?? 'Not specified',
        'location': materialData['location']?.toString() ?? '',
        'delivery_option': materialData['delivery_option']?.toString() ?? 'Needs Pickup',
        'available_from': materialData['available_from']?.toString(),
        'available_until': materialData['available_until']?.toString(),
        'is_fragile': materialData['is_fragile'] ?? false,
        'contact_preferences': materialData['contact_preferences'] ?? {},
        'image_urls': imageUrls,
        'uploader_id': materialData['uploader_id'] ?? 3,
      };

      print('📦 Sending material data to server...');
      print('📦 Data being sent: ${json.encode(requestData)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/materials'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print('📡 Server response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        print('✅ Material created successfully');
        return true;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Server error: ${errorData['error']}');
        throw Exception(errorData['error'] ?? 'Failed to create material');
      }
    } catch (e) {
      print('❌ Create material error: $e');
      rethrow;
    }
  }

  // Get all materials
  static Future<List<dynamic>> getMaterials() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/materials'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load materials');
      }
    } catch (e) {
      print('Error loading materials: $e');
      throw Exception('Failed to load materials: $e');
    }
  }

  // Claim a material
  static Future<bool> claimMaterial(String materialId, int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/materials/$materialId/claim'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'claimed_by': userId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to claim material');
      }
    } catch (e) {
      print('Error claiming material: $e');
      throw Exception('Failed to claim material: $e');
    }
  }
}