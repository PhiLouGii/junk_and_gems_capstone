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
      
      List<String> imageUrls = [];
      
      if (images.isNotEmpty) {
        print('Uploading ${images.length} images to Cloudinary...');
        imageUrls = await CloudinaryService.uploadMultipleImages(images);
        
        if (imageUrls.isEmpty) {
          print('Warning: No images uploaded successfully');
        } else {
          print('Successfully uploaded ${imageUrls.length} images');
          print('Image URLs:');
          for (int i = 0; i < imageUrls.length; i++) {
            print('   ${i + 1}. ${imageUrls[i]}');
          }
        }
      } else {
        print('No images to upload');
      }
      
      // Prepare the final data
      final Map<String, dynamic> requestData = {
        'title': productData['title']?.toString() ?? '',
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'] is String 
            ? double.tryParse(productData['price']) ?? 0.0 
            : productData['price'] ?? 0.0,
        'category': productData['category']?.toString() ?? '',
        'condition': productData['condition']?.toString() ?? '',
        'materials_used': productData['materials_used']?.toString(),
        'dimensions': productData['dimensions']?.toString(),
        'location': productData['location']?.toString(),
        'artisan_id': productData['artisan_id'] is String 
            ? int.tryParse(productData['artisan_id']) ?? 0 
            : productData['artisan_id'] ?? 0,
        'creator_name': productData['creator_name']?.toString() ?? 'Unknown',
        'image_urls': imageUrls,
      };

      print('Sending product data to server...');
      print('Product details:');
      print('   - Title: ${requestData['title']}');
      print('   - Price: ${requestData['price']}');
      print('   - Category: ${requestData['category']}');
      print('   - Artisan ID: ${requestData['artisan_id']}');
      print('   - Images: ${imageUrls.length}');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 30));

      print('Server response: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Product created successfully!');
        print('Response: ${response.body}');
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
      ).timeout(Duration(seconds: 90));

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        print('Fetched ${products.length} products');
        
        // Log first product to see structure
        if (products.isNotEmpty) {
          print('   Sample product structure:');
          print('   ID: ${products[0]['id']}');
          print('   Title: ${products[0]['title']}');
          print('   Has image_urls: ${products[0]['image_urls'] != null}');
          print('   Has image_data_base64: ${products[0]['image_data_base64'] != null}');
          
          if (products[0]['image_urls'] != null) {
            print('   image_urls type: ${products[0]['image_urls'].runtimeType}');
            if (products[0]['image_urls'] is List) {
              final imageUrls = products[0]['image_urls'] as List;
              print('   image_urls count: ${imageUrls.length}');
              if (imageUrls.isNotEmpty) {
                print('   First URL: ${imageUrls[0]}');
              }
            }
          }
          
          if (products[0]['image_data_base64'] != null) {
            print('   image_data_base64 type: ${products[0]['image_data_base64'].runtimeType}');
            if (products[0]['image_data_base64'] is List) {
              final imageData = products[0]['image_data_base64'] as List;
              print('   image_data_base64 count: ${imageData.length}');
              if (imageData.isNotEmpty) {
                final firstItem = imageData[0].toString();
                if (firstItem.startsWith('http')) {
                  print('   First item is URL: ${firstItem}');
                } else if (firstItem.startsWith('data:image')) {
                  print('   First item is base64 (length: ${firstItem.length})');
                } else {
                  print('   First item unknown format: ${firstItem.substring(0, 50)}...');
                }
              }
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