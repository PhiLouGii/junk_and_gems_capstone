import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

class ProductService {
  static const String _baseUrl = 'https://junk-and-gems-api.onrender.com';

  static Future<bool> createProduct(
      Map<String, dynamic> productData, List<XFile> images) async {
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
      
      // Prepare the final data
      final Map<String, dynamic> requestData = {
        'title': productData['title']?.toString() ?? '',
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'] ?? 0.0,
        'category': productData['category']?.toString() ?? '',
        'condition': productData['condition']?.toString() ?? '',
        'materials_used': productData['materials_used']?.toString(),
        'dimensions': productData['dimensions']?.toString(),
        'location': productData['location']?.toString(),
        'artisan_id': productData['artisan_id'] ?? 0,
        'creator_name': productData['creator_name']?.toString() ?? 'Unknown',
        'image_urls': imageUrls,
      };

      print('📦 Sending product data to server...');
      print('📦 Data being sent: ${json.encode(requestData)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 30));

      print('📡 Server response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        print('✅ Product created successfully');
        return true;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Server error: ${errorData['error']}');
        throw Exception(errorData['error'] ?? 'Failed to create product');
      }
    } catch (e) {
      print('❌ Create product error: $e');
      rethrow;
    }
  }

  // Get all products
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/products')
      ).timeout(Duration(seconds: 90));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error loading products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
}