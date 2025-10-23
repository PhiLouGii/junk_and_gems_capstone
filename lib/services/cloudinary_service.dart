import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class CloudinaryService {
  static const String _baseUrl = 'https://junk-and-gems-api.onrender.com';

  /// Compress image before upload (crucial for physical devices)
  static Future<File?> _compressImage(File file) async {
    try {
      print('📦 Compressing image...');
      print('   Original path: ${file.path}');
      
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70, // Balance between quality and size
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );
      
      if (result != null) {
        final originalSize = await file.length();
        final compressedSize = await File(result.path).length();
        
        print('✅ Compression complete:');
        print('   Original: ${(originalSize / 1024).toStringAsFixed(2)} KB');
        print('   Compressed: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
        print('   Saved: ${((originalSize - compressedSize) / 1024).toStringAsFixed(2)} KB');
        
        return File(result.path);
      }
      
      print('⚠️ Compression returned null, using original');
      return file;
    } catch (e) {
      print('❌ Compression error: $e');
      print('   Using original file');
      return file;
    }
  }

  /// Upload single image with retry logic
  static Future<String?> uploadImage(File imageFile, {int maxRetries = 3}) async {
    // Compress image first
    final File? compressedFile = await _compressImage(imageFile);
    if (compressedFile == null) {
      print('❌ Failed to prepare image for upload');
      return null;
    }

    // Attempt upload with retries
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('\n🔄 Upload attempt $attempt/$maxRetries...');
        print('   File path: ${compressedFile.path}');
        
        // Verify file exists
        if (!await compressedFile.exists()) {
          print('❌ File does not exist: ${compressedFile.path}');
          return null;
        }
        
        final fileSize = await compressedFile.length();
        print('   File size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)');
        
        // Check size limit (5MB for reliability on mobile)
        if (fileSize > 5 * 1024 * 1024) {
          print('❌ File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB (max 5MB)');
          return null;
        }
        
        if (fileSize == 0) {
          print('❌ File is empty');
          return null;
        }
        
        // Read and encode image with data URL prefix (required by backend)
        List<int> imageBytes = await compressedFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        String imageData = 'data:image/jpeg;base64,$base64Image';
        
        print('   Base64 encoded: ${imageData.length} characters');
        print('   Sending to: $_baseUrl/api/upload-image');

        // Upload with timeout (using same field name as original working code)
        final response = await http.post(
          Uri.parse('$_baseUrl/api/upload-image'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'image_data_base64': imageData}),
        ).timeout(
          const Duration(seconds: 90), // Longer timeout for mobile networks
          onTimeout: () {
            throw Exception('Upload timeout after 90 seconds');
          },
        );

        print('   Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          try {
            final Map<String, dynamic> responseData = json.decode(response.body);
            print('   Response data: $responseData');
            
            final String? imageUrl = responseData['image_url'];
            
            if (imageUrl != null && imageUrl.isNotEmpty) {
              if (imageUrl.startsWith('https://res.cloudinary.com/') ||
                  imageUrl.startsWith('http://') || 
                  imageUrl.startsWith('https://')) {
                print('✅ Upload successful!');
                print('   Cloudinary URL: $imageUrl');
                return imageUrl;
              } else {
                print('⚠️ Invalid URL format: $imageUrl');
              }
            } else {
              print('⚠️ No image URL in response');
              print('   Full response: ${response.body}');
            }
          } catch (jsonError) {
            print('❌ JSON decode error: $jsonError');
            print('   Response body: ${response.body}');
          }
        } else {
          print('❌ Server error: ${response.statusCode}');
          print('   Response: ${response.body}');
        }

        // Wait before retry (exponential backoff)
        if (attempt < maxRetries) {
          final waitTime = attempt * 2; // 2s, 4s, 6s
          print('⏳ Waiting ${waitTime}s before retry...');
          await Future.delayed(Duration(seconds: waitTime));
        }

      } on SocketException catch (e) {
        print('❌ Network error: $e');
        if (attempt == maxRetries) {
          print('💡 Check your internet connection');
        }
      } on TimeoutException catch (e) {
        print('❌ Timeout error: $e');
        if (attempt == maxRetries) {
          print('💡 Upload took too long, network may be slow');
        }
      } on http.ClientException catch (e) {
        print('❌ HTTP client error: $e');
      } catch (e) {
        print('❌ Unexpected error: $e');
      }

      // Wait before retry
      if (attempt < maxRetries) {
        final waitTime = attempt * 2;
        print('⏳ Waiting ${waitTime}s before retry...');
        await Future.delayed(Duration(seconds: waitTime));
      }
    }
    
    print('❌ All $maxRetries upload attempts failed');
    return null;
  }

  /// Upload multiple images with compression and retry
  static Future<List<String>> uploadMultipleImages(List<XFile> xFiles) async {
    List<String> uploadedUrls = [];
    int successCount = 0;
    int failCount = 0;
    
    print('\n============================================================');
    print('CLOUDINARY UPLOAD STARTED');
    print('============================================================');
    print('📸 Total images to upload: ${xFiles.length}');
    
    for (int i = 0; i < xFiles.length; i++) {
      print('\n📤 Processing image ${i + 1}/${xFiles.length}...');
      
      try {
        final File imageFile = File(xFiles[i].path);
        
        // Verify file exists
        if (!await imageFile.exists()) {
          print('❌ File does not exist: ${xFiles[i].path}');
          failCount++;
          continue;
        }
        
        // Upload with retry logic
        final String? imageUrl = await uploadImage(imageFile);
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          uploadedUrls.add(imageUrl);
          successCount++;
          print('✅ Image ${i + 1} uploaded successfully!');
          print('   URL: $imageUrl');
        } else {
          failCount++;
          print('❌ Failed to upload image ${i + 1}');
        }
        
      } catch (e) {
        failCount++;
        print('❌ Error processing image ${i + 1}: $e');
      }
    }
    
    print('\n============================================================');
    print('UPLOAD SUMMARY');
    print('============================================================');
    print('✅ Successful: $successCount');
    print('❌ Failed: $failCount');
    print('📊 Total URLs: ${uploadedUrls.length}');
    
    if (uploadedUrls.isNotEmpty) {
      print('\n📋 Uploaded URLs:');
      for (int i = 0; i < uploadedUrls.length; i++) {
        print('   ${i + 1}. ${uploadedUrls[i]}');
      }
    }
    
    print('============================================================\n');
    
    return uploadedUrls;
  }
}