import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _baseUrl = 'http://10.0.2.2:3003';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Read the image file and convert to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String imageData = 'data:image/jpeg;base64,$base64Image';

      final response = await http.post(
        Uri.parse('$_baseUrl/api/upload-image'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image_data_base64': imageData}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['image_url'];
      } else {
        print('❌ Image upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Image upload error: $e');
      return null;
    }
  }

  static Future<List<String>> uploadMultipleImages(List<XFile> xFiles) async {
    List<String> uploadedUrls = [];
    
    for (var xFile in xFiles) {
      final File imageFile = File(xFile.path);
      final String? imageUrl = await uploadImage(imageFile);
      
      if (imageUrl != null) {
        uploadedUrls.add(imageUrl);
      }
    }
    
    return uploadedUrls;
  }
}