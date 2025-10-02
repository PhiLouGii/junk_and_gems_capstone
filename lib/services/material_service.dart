// services/material_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MaterialService {
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // Upload single image
  static Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/api/upload-image')
      );
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', 
          imageFile.path
        )
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      
      if (response.statusCode == 200 && jsonResponse['success']) {
        return jsonResponse['imageUrl'];
      } else {
        throw Exception(jsonResponse['error'] ?? 'Upload failed');
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Image upload failed: $e');
    }
  }

  // Upload multiple images
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/api/upload-images')
      );
      
      for (var imageFile in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', 
            imageFile.path
          )
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      
      if (response.statusCode == 200 && jsonResponse['success']) {
        return List<String>.from(jsonResponse['imageUrls']);
      } else {
        throw Exception(jsonResponse['error'] ?? 'Upload failed');
      }
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Image upload failed: $e');
    }
  }

  // Get all materials
  static Future<List<dynamic>> getMaterials() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/materials'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load materials');
      }
    } catch (e) {
      print('Error fetching materials: $e');
      throw Exception('Network error');
    }
  }
  
  // Create new material/donation
  static Future<Map<String, dynamic>> createMaterial(Map<String, dynamic> materialData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');
      
      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Add uploader_id to material data
      materialData['uploader_id'] = userId;
      
      final response = await http.post(
        Uri.parse('$baseUrl/materials'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(materialData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create material');
      }
    } catch (e) {
      print('Error creating material: $e');
      throw Exception('Failed to create material: $e');
    }
  }
}