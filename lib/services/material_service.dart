import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

class MaterialService {
  static const String _baseUrl = 'https://junk-and-gems-api.onrender.com';

  static Future<bool> createMaterial(
      Map<String, dynamic> materialData, List<XFile> images) async {
    try {
      print('=' * 60);
      print('CREATING NEW MATERIAL');
      print('=' * 60);
      
      // STEP 1: Upload images to Cloudinary first (if any provided)
      List<String> imageUrls = [];
      
      if (images.isNotEmpty) {
        print('📸 Uploading ${images.length} images to Cloudinary...');
        imageUrls = await CloudinaryService.uploadMultipleImages(images);
        
        if (imageUrls.isEmpty) {
          print('⚠️ No images uploaded, but continuing without images');
        } else {
          print('✅ Successfully uploaded ${imageUrls.length} images');
          print('Image URLs:');
          for (int i = 0; i < imageUrls.length; i++) {
            print('   ${i + 1}. ${imageUrls[i]}');
            
            // Verify URL format
            if (!imageUrls[i].startsWith('http')) {
              print('⚠️ Warning: URL ${i + 1} is not a valid HTTP URL');
            }
          }
        }
      } else {
        print('ℹ️ No images provided for this material');
      }
      
      // STEP 2: Prepare material data with Cloudinary URLs
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
        'image_data_base64': imageUrls,  // Send Cloudinary URLs as array
        'uploader_id': materialData['uploader_id'],
        'location_area': materialData['location_area'] ?? '',
      'location_landmark': materialData['location_landmark'] ?? '',
      'location_directions': materialData['location_directions'] ?? '',
      };

      print(' Sending material data to server...');
      print('Material details:');
      print('   - Title: ${requestData['title']}');
      print('   - Category: ${requestData['category']}');
      print('   - Location: ${requestData['location']}');
      print('   - Uploader ID: ${requestData['uploader_id']}');
      print('   - Images: ${imageUrls.length} Cloudinary URLs');

      // STEP 3: Send to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/materials'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 30));

      print('📡 Server response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        print('✅ Material created successfully!');
        
        // Parse response to verify images were stored
        final responseData = json.decode(response.body);
        print('Response data:');
        print('   - Material ID: ${responseData['id']}');
        print('   - Title: ${responseData['title']}');
        
        if (responseData['image_urls'] != null) {
          final storedUrls = responseData['image_urls'] as List;
          print('   - ✅ Stored ${storedUrls.length} image URLs');
        } else if (responseData['image_data_base64'] != null) {
          final storedUrls = responseData['image_data_base64'] as List;
          print('   - ✅ Stored ${storedUrls.length} images in image_data_base64');
        } else {
          print('   - ⚠️ Warning: No image data in response');
        }
        
        print('=' * 60);
        return true;
      } else {
        print('❌ Server returned error status: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to create material');
        } catch (e) {
          throw Exception('Failed to create material: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Create material error: $e');
      print('=' * 60);
      rethrow;
    }
  }

  // Get all materials
  static Future<List<dynamic>> getMaterials() async {
    try {
      print('📥 Fetching materials from server...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/materials')
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final List<dynamic> materials = json.decode(response.body);
        print('✅ Fetched ${materials.length} materials');
        
        // Log first material to see structure
        if (materials.isNotEmpty) {
          final firstMaterial = materials[0];
          print('📦 Sample material:');
          print('   - ID: ${firstMaterial['id']}');
          print('   - Title: ${firstMaterial['title']}');
          
          // Check both possible image fields
          if (firstMaterial['image_data_base64'] != null) {
            final imageData = firstMaterial['image_data_base64'];
            if (imageData is List && imageData.isNotEmpty) {
              print('   - image_data_base64: ${imageData.length} images');
              final firstUrl = imageData[0].toString();
              if (firstUrl.startsWith('http')) {
                print('   - ✅ First image is Cloudinary URL');
              } else {
                print('   - Format: ${firstUrl.substring(0, 50)}...');
              }
            }
          }
          
          if (firstMaterial['image_urls'] != null) {
            final imageUrls = firstMaterial['image_urls'];
            if (imageUrls is List && imageUrls.isNotEmpty) {
              print('   - image_urls: ${imageUrls.length} images');
            }
          }
        }
        
        return materials;
      } else {
        print('❌ Failed to load materials: ${response.statusCode}');
        throw Exception('Failed to load materials');
      }
    } catch (e) {
      print('❌ Error loading materials: $e');
      throw Exception('Failed to load materials: $e');
    }
  }

  // Claim a material
  static Future<bool> claimMaterial(String materialId, int userId) async {
    try {
      print('🎯 Claiming material $materialId for user $userId');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/materials/$materialId/claim'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'claimed_by': userId}),
      );

      if (response.statusCode == 200) {
        print('✅ Material claimed successfully');
        return true;
      } else {
        print('❌ Failed to claim material: ${response.statusCode}');
        throw Exception('Failed to claim material');
      }
    } catch (e) {
      print(' Error claiming material: $e');
      throw Exception('Failed to claim material: $e');
    }
  }
}