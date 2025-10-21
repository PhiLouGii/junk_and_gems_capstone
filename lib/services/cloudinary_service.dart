import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _baseUrl = 'https://junk-and-gems-api.onrender.com';

  static Future<String?> uploadImage(File imageFile) async {
  try {
    print('Uploading image to Cloudinary...');
    
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    String imageData = 'data:image/jpeg;base64,$base64Image';

    final response = await http.post(
      Uri.parse('$_baseUrl/api/upload-image'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'image_data_base64': imageData}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String? imageUrl = responseData['image_url'];
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Ensure it's a proper URL
        if (!imageUrl.startsWith('http')) {
          print('Image URL does not start with http: $imageUrl');
        }
        print('Image uploaded: $imageUrl');
        return imageUrl;
      } else {
        print('No image URL in response');
        return null;
      }
    } else {
      print('Upload failed: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}

  static Future<List<String>> uploadMultipleImages(List<XFile> xFiles) async {
    List<String> uploadedUrls = [];
    
    print('Starting upload of ${xFiles.length} images...');
    
    for (int i = 0; i < xFiles.length; i++) {
      print('Uploading image ${i + 1}/${xFiles.length}...');
      
      final File imageFile = File(xFiles[i].path);
      final String? imageUrl = await uploadImage(imageFile);
      
      if (imageUrl != null) {
        uploadedUrls.add(imageUrl);
        print('Image ${i + 1} uploaded: $imageUrl');
      } else {
        print('Failed to upload image ${i + 1}');
      }
    }
    
    print('Upload complete: ${uploadedUrls.length}/${xFiles.length} successful');
    return uploadedUrls;
  }
}