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
      print('=' * 80);
      print(' CREATING NEW MATERIAL');
      print('=' * 80);
      print(' Material data received:');
      print('   Title: ${materialData['title']}');
      print('   Category: ${materialData['category']}');
      print('   Uploader ID: ${materialData['uploader_id']}');
      print(' Images received: ${images.length}');
      
      // STEP 1: Upload images to Cloudinary first (if any provided)
      List<String> imageUrls = [];
      
      if (images.isNotEmpty) {
        print('\n UPLOADING ${images.length} IMAGES TO CLOUDINARY...');
        print('─' * 80);
        
        // Verify each image file exists before uploading
        List<XFile> validImages = [];
        for (int i = 0; i < images.length; i++) {
          final file = File(images[i].path);
          if (await file.exists()) {
            final size = await file.length();
            print(' Image ${i + 1}: ${images[i].path}');
            print('   Size: ${(size / 1024).toStringAsFixed(2)} KB');
            validImages.add(images[i]);
          } else {
            print(' Image ${i + 1} does not exist: ${images[i].path}');
          }
        }
        
        if (validImages.isEmpty) {
          print('\n⚠️ WARNING: No valid images found after verification!');
          print('Continuing without images...');
        } else {
          print('\n Uploading ${validImages.length} valid images...');
          
          try {
            imageUrls = await CloudinaryService.uploadMultipleImages(validImages);
            print('\n UPLOAD RESULTS:');
            print('   Attempted: ${validImages.length}');
            print('   Successful: ${imageUrls.length}');
            print('   Failed: ${validImages.length - imageUrls.length}');
            
            if (imageUrls.isEmpty) {
              print('\n ERROR: All image uploads failed!');
              print(' Material will be created WITHOUT images');
              print(' Possible causes:');
              print('   • Network connectivity issues');
              print('   • Cloudinary service unavailable');
              print('   • Image file corruption');
              print('   • Upload timeout');
            } else if (imageUrls.length < validImages.length) {
              print('\n⚠️ WARNING: Some images failed to upload');
              print(' Successfully uploaded URLs:');
              for (int i = 0; i < imageUrls.length; i++) {
                print('   ${i + 1}. ${imageUrls[i]}');
              }
            } else {
              print('\n ALL IMAGES UPLOADED SUCCESSFULLY!');
              for (int i = 0; i < imageUrls.length; i++) {
                print('   ${i + 1}. ${imageUrls[i]}');
                
                // Verify URL format
                if (!imageUrls[i].startsWith('http')) {
                  print('    WARNING: URL ${i + 1} is not a valid HTTP URL');
                }
              }
            }
          } catch (uploadError) {
            print('\n CLOUDINARY UPLOAD EXCEPTION: $uploadError');
            print('Stack trace: ${StackTrace.current}');
            print(' Continuing without images...');
          }
        }
        
        print('─' * 80);
      } else {
        print('\nℹ️ No images provided for this material');
      }
      
      // STEP 2: Prepare material data with Cloudinary URLs
      print('\n PREPARING MATERIAL DATA FOR BACKEND...');
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
        'image_urls': imageUrls,   // Send Cloudinary URLs as array
        'uploader_id': materialData['uploader_id'],
        'location_area': materialData['location_area'] ?? '',
        'location_landmark': materialData['location_landmark'] ?? '',
        'location_directions': materialData['location_directions'] ?? '',
        'latitude': materialData['latitude'],
        'longitude': materialData['longitude'],
        'map_address': materialData['map_address'],
        'is_map_location': materialData['is_map_location'],
      };

      print('Material payload:');
      print('   Title: ${requestData['title']}');
      print('   Category: ${requestData['category']}');
      print('   Location: ${requestData['location']}');
      print('   Uploader ID: ${requestData['uploader_id']}');
      print('   Image URLs: ${imageUrls.length}');
      if (imageUrls.isNotEmpty) {
        print('   First image: ${imageUrls[0]}');
      }

      // STEP 3: Send to backend
      print('\n SENDING TO BACKEND...');
      print('   URL: $_baseUrl/materials');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/materials'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Backend request timed out after 30 seconds');
        },
      );

      print('Backend response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        print('MATERIAL CREATED SUCCESSFULLY!');
        
        // Parse response to verify images were stored
        try {
          final responseData = json.decode(response.body);
          print('\n Backend confirmation:');
          print('   Material ID: ${responseData['id']}');
          print('   Title: ${responseData['title']}');
          
          // Check the correct field name
          if (responseData['image_urls'] != null) {
            final storedUrls = responseData['image_urls'] as List;
            print('   Stored ${storedUrls.length} image URLs');
            
            if (storedUrls.isEmpty && imageUrls.isNotEmpty) {
              print('   WARNING: We sent ${imageUrls.length} URLs but backend stored 0!');
            } else if (storedUrls.length != imageUrls.length) {
              print('   WARNING: Mismatch - sent ${imageUrls.length}, stored ${storedUrls.length}');
            } else if (storedUrls.isNotEmpty) {
              print('   All images stored correctly');
              for (int i = 0; i < storedUrls.length; i++) {
                print('      ${i + 1}. ${storedUrls[i]}');
              }
            }
          } else if (responseData['image_data_base64'] != null) {
            final storedUrls = responseData['image_data_base64'] as List;
            print('   Stored ${storedUrls.length} images in image_data_base64');
          } else {
            print('WARNING: No image_urls or image_data_base64 in response');
            print('   Available keys: ${responseData.keys.toList()}');
          }
        } catch (e) {
          print('Could not parse response for verification: $e');
        }
        
        print('=' * 80);
        return true;
      } else {
        print('BACKEND ERROR: ${response.statusCode}');
        print('Response: ${response.body}');
        
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to create material');
        } catch (e) {
          throw Exception('Backend error ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e, stackTrace) {
      print('\n CREATE MATERIAL ERROR: $e');
      print('Stack trace:');
      print(stackTrace);
      print('=' * 80);
      rethrow;
    }
  }

  // Get all materials
  static Future<List<dynamic>> getMaterials() async {
    try {
      print('Fetching materials from server...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/materials')
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final List<dynamic> materials = json.decode(response.body);
        print('Fetched ${materials.length} materials');
        
        // Log first material to see structure
        if (materials.isNotEmpty) {
          final firstMaterial = materials[0];
          print('Sample material structure:');
          print('   ID: ${firstMaterial['id']}');
          print('   Title: ${firstMaterial['title']}');
          
          // Check both possible image fields
          if (firstMaterial['image_data_base64'] != null) {
            final imageData = firstMaterial['image_data_base64'];
            if (imageData is List && imageData.isNotEmpty) {
              print('   image_data_base64: ${imageData.length} images');
              final firstUrl = imageData[0].toString();
              if (firstUrl.startsWith('http')) {
                print('   First image is Cloudinary URL ✅');
              } else {
                print('   Format: ${firstUrl.substring(0, 50)}...');
              }
            }
          }
          
          if (firstMaterial['image_urls'] != null) {
            final imageUrls = firstMaterial['image_urls'];
            if (imageUrls is List && imageUrls.isNotEmpty) {
              print('   image_urls: ${imageUrls.length} images');
            }
          }
        }
        
        return materials;
      } else {
        print('Failed to load materials: ${response.statusCode}');
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
      print('Claiming material $materialId for user $userId');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/materials/$materialId/claim'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'claimed_by': userId}),
      );

      if (response.statusCode == 200) {
        print('Material claimed successfully');
        return true;
      } else {
        print('Failed to claim material: ${response.statusCode}');
        throw Exception('Failed to claim material');
      }
    } catch (e) {
      print('Error claiming material: $e');
      throw Exception('Failed to claim material: $e');
    }
  }
}