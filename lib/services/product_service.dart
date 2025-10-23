import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

class ProductService {
  static const String _baseUrl = 'https://junk-and-gems-api.onrender.com';

  static Future<bool> createProduct(
      Map<String, dynamic> productData, List<XFile> images) async {
    try {
      print('=' * 60);
      print('CREATING NEW PRODUCT');
      print('=' * 60);
      
      // STEP 1: Validate images first
      if (images.isEmpty) {
        print('❌ Error: No images provided');
        throw Exception('At least one image is required');
      }
      
      print('📸 Images to process: ${images.length}');
      
      // STEP 2: Upload images to Cloudinary with the NEW compression method
      print('\n🚀 Starting Cloudinary upload...');
      List<String> imageUrls = [];
      
      try {
        imageUrls = await CloudinaryService.uploadMultipleImages(images);
        print('\n📊 Upload completed: ${imageUrls.length}/${images.length} successful');
      } catch (uploadError) {
        print('❌ Upload exception: $uploadError');
        throw Exception('Image upload failed: ${uploadError.toString()}');
      }
      
      // STEP 3: Validate upload results
      if (imageUrls.isEmpty) {
        print('❌ Error: All image uploads failed');
        print('💡 Troubleshooting tips:');
        print('   • Check your internet connection');
        print('   • Try using WiFi instead of mobile data');
        print('   • Try uploading fewer or smaller images');
        throw Exception(
          'Failed to upload images. Please check your internet connection and try again.'
        );
      }
      
      if (imageUrls.length < images.length) {
        print('⚠️ Warning: Only ${imageUrls.length}/${images.length} images uploaded');
        // Continue anyway with the images that did upload
      }
      
      print('\n✅ Successfully uploaded ${imageUrls.length} images:');
      for (int i = 0; i < imageUrls.length; i++) {
        print('   ${i + 1}. ${imageUrls[i]}');
        
        // Verify URL format
        if (!imageUrls[i].startsWith('http')) {
          print('   ⚠️ Warning: URL ${i + 1} is not a valid HTTP URL');
        }
      }
      
      // STEP 4: Prepare product data with Cloudinary URLs
      final Map<String, dynamic> requestData = {
        'title': productData['title']?.toString() ?? '',
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'] is String 
            ? double.tryParse(productData['price']) ?? 0.0 
            : (productData['price'] ?? 0.0),
        'category': productData['category']?.toString() ?? '',
        'condition': productData['condition']?.toString() ?? '',
        'materials_used': productData['materials_used']?.toString() ?? '',
        'dimensions': productData['dimensions']?.toString() ?? '',
        'location': productData['location']?.toString() ?? '',
        'artisan_id': productData['artisan_id'] is String 
            ? int.tryParse(productData['artisan_id']) ?? 0 
            : (productData['artisan_id'] ?? 0),
        'creator_name': productData['creator_name']?.toString() ?? 'Unknown',
        'image_urls': imageUrls,  // Send Cloudinary URLs as array
      };

      print('\n📤 Sending product data to server...');
      print('Product details:');
      print('   - Title: ${requestData['title']}');
      print('   - Price: M${requestData['price']}');
      print('   - Category: ${requestData['category']}');
      print('   - Artisan ID: ${requestData['artisan_id']}');
      print('   - Creator: ${requestData['creator_name']}');
      print('   - Images: ${imageUrls.length} Cloudinary URLs');
      
      // STEP 5: Send to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/api/products'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Server timeout - please try again');
        },
      );

      print('\n📡 Server response: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Product created successfully!');
        
        // Parse response to verify images were stored
        try {
          final responseData = json.decode(response.body);
          print('Response data:');
          print('   - Product ID: ${responseData['id']}');
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
        } catch (e) {
          print('   - ⚠️ Could not parse response: $e');
        }
        
        print('=' * 60);
        return true;
      } else {
        print('❌ Server returned error status: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to create product');
        } catch (e) {
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } on Exception catch (e) {
      print('❌ Create product error: $e');
      print('=' * 60);
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      print('=' * 60);
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Get all products
  static Future<List<dynamic>> getProducts() async {
    try {
      print('Fetching products from server...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/products')
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        print('Fetched ${products.length} products');
        
        // Log first product to see structure
        if (products.isNotEmpty) {
          final firstProduct = products[0];
          print('   Sample product:');
          print('   - ID: ${firstProduct['id']}');
          print('   - Title: ${firstProduct['title']}');
          
          // Check both possible image fields
          if (firstProduct['image_data_base64'] != null) {
            final imageData = firstProduct['image_data_base64'];
            if (imageData is List && imageData.isNotEmpty) {
              print('   - image_data_base64: ${imageData.length} images');
              final firstUrl = imageData[0].toString();
              if (firstUrl.startsWith('http')) {
                print('   - First image is Cloudinary URL ✅');
              } else {
                print('   - First image format: ${firstUrl.substring(0, 50)}...');
              }
            }
          }
          
          if (firstProduct['image_urls'] != null) {
            final imageUrls = firstProduct['image_urls'];
            if (imageUrls is List && imageUrls.isNotEmpty) {
              print('   - image_urls: ${imageUrls.length} images');
            }
          }
        }
        
        return products;
      } else {
        print('Failed to load products: ${response.statusCode}');
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error loading products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
}