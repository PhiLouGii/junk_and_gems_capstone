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
      
      // Upload images to Cloudinary first
      List<String> imageUrls = await CloudinaryService.uploadMultipleImages(images);
      
      print('✅ Image upload complete. Got ${imageUrls.length} URLs');
      
      // Add Cloudinary URLs to material data
      materialData['image_urls'] = imageUrls;
      
      // Remove any base64 image data if present
      materialData.remove('image_data_base64');

      print('📦 Sending material data to server...');
      final response = await http.post(
        Uri.parse('$_baseUrl/materials'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(materialData),
      );

      print('📡 Server response: ${response.statusCode}');
      
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

  // Get user's posted materials
  static Future<List<dynamic>> getUserMaterials(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/materials'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user materials');
      }
    } catch (e) {
      print('Error loading user materials: $e');
      throw Exception('Failed to load user materials: $e');
    }
  }

  // Get material by ID
  static Future<dynamic> getMaterialById(String materialId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/materials/$materialId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load material details');
      }
    } catch (e) {
      print('Error loading material details: $e');
      throw Exception('Failed to load material details: $e');
    }
  }

  // Delete material
  static Future<bool> deleteMaterial(String materialId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/materials/$materialId'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete material');
      }
    } catch (e) {
      print('Error deleting material: $e');
      throw Exception('Failed to delete material: $e');
    }
  }
}