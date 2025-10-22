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
      
      // STEP 1: Upload images to Cloudinary first
      List<String> imageUrls = [];
      
      if (images.isNotEmpty) {
        print('Uploading ${images.length} images to Cloudinary...');
        imageUrls = await CloudinaryService.uploadMultipleImages(images);
        
        if (imageUrls.isEmpty) {
          print('Error: No images uploaded successfully');
          throw Exception('Failed to upload images to Cloudinary');
        } else {
          print('Successfully uploaded ${imageUrls.length} images');
          print('Image URLs:');
          for (int i = 0; i < imageUrls.length; i++) {
            print('   ${i + 1}. ${imageUrls[i]}');
            
            // Verify URL format
            if (!imageUrls[i].startsWith('http')) {
              print('Warning: URL ${i + 1} is not a valid HTTP URL');
            }
          }
        }
      } else {
        print('No images provided');
        throw Exception('At least one image is required');
      }
      
      // STEP 2: Prepare product data with Cloudinary URLs
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
        'image_urls': imageUrls,  // CRITICAL: Send Cloudinary URLs as array
      };

      print('Sending product data to server...');
      print('Product details:');
      print('   - Title: ${requestData['title']}');
      print('   - Price: M${requestData['price']}');
      print('   - Category: ${requestData['category']}');
      print('   - Artisan ID: ${requestData['artisan_id']}');
      print('   - Creator: ${requestData['creator_name']}');
      print('   - Images: ${imageUrls.length} Cloudinary URLs');
      
      // STEP 3: Send to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/api/products'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 30));

      print('Server response: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Product created successfully!');
        
        // Parse response to verify images were stored
        final responseData = json.decode(response.body);
        print('Response data:');
        print('   - Product ID: ${responseData['id']}');
        print('   - Title: ${responseData['title']}');
        
        if (responseData['image_urls'] != null) {
          final storedUrls = responseData['image_urls'] as List;
          print('   - Stored ${storedUrls.length} image URLs');
        } else if (responseData['image_data_base64'] != null) {
          final storedUrls = responseData['image_data_base64'] as List;
          print('   - Stored ${storedUrls.length} images in image_data_base64');
        } else {
          print('Warning: No image data in response');
        }
        
        print('=' * 60);
        return true;
      } else {
        print('Server returned error status: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to create product');
        } catch (e) {
          throw Exception('Failed to create product: ${response.body}');
        }
      }
    } catch (e) {
      print('Create product error: $e');
      print('=' * 60);
      rethrow;
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