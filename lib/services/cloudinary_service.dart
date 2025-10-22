import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _baseUrl = 'https://junk-and-gems-api.onrender.com';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      print('  Uploading image to Cloudinary...');
      print('   File path: ${imageFile.path}');
      print('   File size: ${await imageFile.length()} bytes');
      
      // Read image and convert to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String imageData = 'data:image/jpeg;base64,$base64Image';
      
      print('   Base64 data length: ${imageData.length} characters');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/upload-image'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image_data_base64': imageData}),
      ).timeout(const Duration(seconds: 30));

      print('   Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String? imageUrl = responseData['image_url'];
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Verify it's a valid Cloudinary URL
          if (imageUrl.startsWith('https://res.cloudinary.com/')) {
            print('   Cloudinary URL received: $imageUrl');
            return imageUrl;
          } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
            print('   URL received but not from Cloudinary: $imageUrl');
            return imageUrl;
          } else {
            print('   Invalid URL format: $imageUrl');
            return null;
          }
        } else {
          print('   No image URL in response');
          print('   Response data: ${response.body}');
          return null;
        }
      } else {
        print('   Upload failed: ${response.statusCode}');
        print('   Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('   Upload error: $e');
      return null;
    }
  }

  static Future<List<String>> uploadMultipleImages(List<XFile> xFiles) async {
    List<String> uploadedUrls = [];
    
    print('Starting upload of ${xFiles.length} images to Cloudinary...');
    
    for (int i = 0; i < xFiles.length; i++) {
      print('\n📸 Uploading image ${i + 1}/${xFiles.length}...');
      
      final File imageFile = File(xFiles[i].path);
      
      // Verify file exists and is readable
      if (!await imageFile.exists()) {
        print('   File does not exist: ${xFiles[i].path}');
        continue;
      }
      
      final String? imageUrl = await uploadImage(imageFile);
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        uploadedUrls.add(imageUrl);
        print('   Image ${i + 1} uploaded successfully');
      } else {
        print('   Failed to upload image ${i + 1}');
      }
    }
    
    print('\n📊 Upload Summary:');
    print('   Total: ${xFiles.length} images');
    print('   Successful: ${uploadedUrls.length} images');
    print('   Failed: ${xFiles.length - uploadedUrls.length} images');
    
    if (uploadedUrls.isNotEmpty) {
      print('\n✅ Uploaded URLs:');
      for (int i = 0; i < uploadedUrls.length; i++) {
        print('   ${i + 1}. ${uploadedUrls[i]}');
      }
    }
    
    return uploadedUrls;
  }
}