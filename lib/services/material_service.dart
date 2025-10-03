import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MaterialService {
  static const String baseUrl = 'http://10.0.2.2:3003'; // Use 10.0.2.2 for Android emulator
  
  // Convert image file to base64
  static Future<String> imageToBase64(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  // Convert multiple images to base64
  static Future<List<String>> imagesToBase64(List<File> imageFiles) async {
    List<String> base64Images = [];
    for (var imageFile in imageFiles) {
      try {
        String base64Image = await imageToBase64(imageFile);
        base64Images.add(base64Image);
      } catch (e) {
        print('Error converting image: $e');
      }
    }
    return base64Images;
  }

  // Create material with base64 images
  static Future<bool> createMaterial(Map<String, dynamic> materialData, List<File> imageFiles) async {
    try {
      print('🚀 Starting material creation...');
      
      // Convert images to base64
      List<String> base64Images = [];
      if (imageFiles.isNotEmpty) {
        print('📸 Converting ${imageFiles.length} images to base64...');
        base64Images = await imagesToBase64(imageFiles);
        print('✅ Images converted successfully');
      }

      // Prepare the final data
      final data = {
        ...materialData,
        'image_data_base64': base64Images,
      };

      print('📦 Sending data to server: ${data.keys}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/materials'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('📡 Server response status: ${response.statusCode}');
      print('📡 Server response body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Material created successfully!');
        return true;
      } else {
        throw Exception('Failed to create material: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating material: $e');
      throw Exception('Failed to create material: $e');
    }
  }

  // Get all materials
  static Future<List<dynamic>> getMaterials() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/materials'));

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
        Uri.parse('$baseUrl/materials/$materialId/claim'),
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