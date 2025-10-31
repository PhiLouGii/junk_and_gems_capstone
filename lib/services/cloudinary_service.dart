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
      print(' Compressing image...');
      print('   Original path: ${file.path}');
      
      // Check file extension to determine format
      final extension = file.path.toLowerCase().split('.').last;
      print('   File extension: $extension');
      
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Determine format based on extension
      CompressFormat format = CompressFormat.jpeg;
      if (extension == 'png') {
        format = CompressFormat.jpeg; // Convert PNG to JPEG for smaller size
        print('   Converting PNG to JPEG');
      } else if (extension == 'heic' || extension == 'heif') {
        format = CompressFormat.jpeg; // Convert HEIC to JPEG
        print('   Converting HEIC to JPEG');
      }
      
      // Get original size before compression
      final originalSize = await file.length();
      print('   Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
      
      // If file is already small enough, try with higher quality
      int quality = 70;
      if (originalSize < 500 * 1024) { // < 500KB
        quality = 85;
        print('   Small file detected, using quality: $quality');
      } else if (originalSize > 5 * 1024 * 1024) { // > 5MB
        quality = 60;
        print('   Large file detected, using quality: $quality');
      }
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
        format: format,
      );
      
      if (result != null) {
        final compressedSize = await File(result.path).length();
        
        // Verify compressed file is not empty
        if (compressedSize == 0) {
          print(' Compression resulted in empty file, using original');
          return file;
        }
        
        // If compression made file bigger (rare), use original
        if (compressedSize > originalSize) {
          print(' Compressed file is larger, using original');
          print('   Original: ${(originalSize / 1024).toStringAsFixed(2)} KB');
          print('   Compressed: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
          return file;
        }
        
        print(' Compression complete:');
        print('   Original: ${(originalSize / 1024).toStringAsFixed(2)} KB');
        print('   Compressed: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
        print('   Saved: ${((originalSize - compressedSize) / 1024).toStringAsFixed(2)} KB');
        print('   Compression ratio: ${((1 - compressedSize / originalSize) * 100).toStringAsFixed(1)}%');
        
        return File(result.path);
      }
      
      print(' Compression returned null, using original');
      return file;
    } catch (e) {
      print(' Compression error: $e');
      print('   Error type: ${e.runtimeType}');
      print('   Using original file as fallback');
      return file;
    }
  }

  /// Upload single image with retry logic
  static Future<String?> uploadImage(File imageFile, {int maxRetries = 3}) async {
    print('\n UPLOAD IMAGE FUNCTION CALLED');
    print('   File: ${imageFile.path}');
    print('   Max retries: $maxRetries');
    
    // Compress image first
    final File? compressedFile = await _compressImage(imageFile);
    if (compressedFile == null) {
      print(' Failed to prepare image for upload');
      return null;
    }

    print('   Using file: ${compressedFile.path}');

    // Attempt upload with retries
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('\n Upload attempt $attempt/$maxRetries...');
        print('   File path: ${compressedFile.path}');
        
        // Verify file exists
        if (!await compressedFile.exists()) {
          print(' File does not exist: ${compressedFile.path}');
          if (attempt < maxRetries) continue;
          return null;
        }
        
        final fileSize = await compressedFile.length();
        print('   File size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)');
        
        // Check size limit (5MB for reliability on mobile)
        if (fileSize > 5 * 1024 * 1024) {
          print(' File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB (max 5MB)');
          return null;
        }
        
        if (fileSize == 0) {
          print(' File is empty');
          return null;
        }
        
        // Read and encode image with data URL prefix (required by backend)
        print('    Reading image bytes...');
        List<int> imageBytes = await compressedFile.readAsBytes();
        
        if (imageBytes.isEmpty) {
          print(' Read 0 bytes from file');
          if (attempt < maxRetries) continue;
          return null;
        }
        
        print('    Read ${imageBytes.length} bytes');
        
        print('    Encoding to base64...');
        String base64Image = '';
        try {
          base64Image = base64Encode(imageBytes);
        } catch (e) {
          print(' Base64 encoding failed: $e');
          if (attempt < maxRetries) continue;
          return null;
        }
        
        if (base64Image.isEmpty) {
          print(' Base64 encoding resulted in empty string');
          if (attempt < maxRetries) continue;
          return null;
        }
        
        String imageData = 'data:image/jpeg;base64,$base64Image';
        print('    Encoded to ${imageData.length} characters');
        
        // Verify data URL is valid
        if (!imageData.startsWith('data:image/jpeg;base64,')) {
          print(' Invalid data URL format');
          if (attempt < maxRetries) continue;
          return null;
        };
        
        print('    Sending to: $_baseUrl/api/upload-image');

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
            print(' Upload timeout after 90 seconds');
            throw Exception('Upload timeout after 90 seconds');
          },
        );

        print('    Response received: ${response.statusCode}');
        print('    Response body length: ${response.body.length} chars');

        if (response.statusCode == 200) {
          try {
            final Map<String, dynamic> responseData = json.decode(response.body);
            print('    Response parsed successfully');
            print('   Response keys: ${responseData.keys.toList()}');
            
            final String? imageUrl = responseData['image_url'];
            
            if (imageUrl != null && imageUrl.isNotEmpty) {
              if (imageUrl.startsWith('https://res.cloudinary.com/') ||
                  imageUrl.startsWith('http://') || 
                  imageUrl.startsWith('https://')) {
                print(' Upload successful!');
                print('   Cloudinary URL: $imageUrl');
                return imageUrl;
              } else {
                print(' Invalid URL format: $imageUrl');
              }
            } else {
              print(' No image URL in response');
              print('   Full response: ${response.body}');
            }
          } catch (jsonError) {
            print(' JSON decode error: $jsonError');
            print('   Response body: ${response.body}');
          }
        } else {
          print(' Server error: ${response.statusCode}');
          print('   Response: ${response.body}');
        }

        // Wait before retry (exponential backoff)
        if (attempt < maxRetries) {
          final waitTime = attempt * 2; // 2s, 4s, 6s
          print(' Waiting ${waitTime}s before retry...');
          await Future.delayed(Duration(seconds: waitTime));
        }

      } on SocketException catch (e) {
        print(' Network error (SocketException): $e');
        if (attempt == maxRetries) {
          print(' No internet connection or server unreachable');
        }
      } on TimeoutException catch (e) {
        print(' Timeout error: $e');
        if (attempt == maxRetries) {
          print(' Upload took too long, network may be slow');
        }
      } on http.ClientException catch (e) {
        print(' HTTP client error: $e');
      } catch (e) {
        print(' Unexpected error: $e');
        print('   Error type: ${e.runtimeType}');
      }

      // Wait before retry
      if (attempt < maxRetries) {
        final waitTime = attempt * 2;
        print(' Waiting ${waitTime}s before next attempt...');
        await Future.delayed(Duration(seconds: waitTime));
      }
    }
    
    print(' All $maxRetries upload attempts failed for this image');
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
    print(' Total images to upload: ${xFiles.length}');
    
    // Validate input
    if (xFiles.isEmpty) {
      print(' No images provided');
      return [];
    }
    
    for (int i = 0; i < xFiles.length; i++) {
      print('\n Processing image ${i + 1}/${xFiles.length}...');
      print('   Path: ${xFiles[i].path}');
      
      try {
        final File imageFile = File(xFiles[i].path);
        
        // Verify file exists and has content
        if (!await imageFile.exists()) {
          print(' File does not exist: ${xFiles[i].path}');
          failCount++;
          continue;
        }
        
        final fileSize = await imageFile.length();
        print('   File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
        
        if (fileSize == 0) {
          print(' File is empty');
          failCount++;
          continue;
        }
        
        // Check if file is readable
        try {
          final testRead = await imageFile.readAsBytes();
          if (testRead.isEmpty) {
            print(' File is not readable');
            failCount++;
            continue;
          }
          print('    File is readable (${testRead.length} bytes)');
        } catch (e) {
          print(' Cannot read file: $e');
          failCount++;
          continue;
        }
        
        // Upload with retry logic
        print('    Starting upload for image ${i + 1}...');
        final String? imageUrl = await uploadImage(imageFile, maxRetries: 3);
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          uploadedUrls.add(imageUrl);
          successCount++;
          print(' Image ${i + 1} uploaded successfully!');
          print('   URL: $imageUrl');
          print('   Total uploaded so far: ${uploadedUrls.length}');
        } else {
          failCount++;
          print(' Failed to upload image ${i + 1} after all retries');
        }
        
        // Small delay between uploads to avoid rate limiting
        if (i < xFiles.length - 1) {
          print('    Waiting 1 second before next upload...');
          await Future.delayed(const Duration(seconds: 1));
        }
        
      } catch (e) {
        failCount++;
        print(' Error processing image ${i + 1}: $e');
        print('   Stack trace: ${StackTrace.current}');
      }
    }
    
    print('\n============================================================');
    print('UPLOAD SUMMARY');
    print('============================================================');
    print(' Successful: $successCount');
    print(' Failed: $failCount');
    print(' Total URLs: ${uploadedUrls.length}');
    
    if (uploadedUrls.isNotEmpty) {
      print('\n Uploaded URLs:');
      for (int i = 0; i < uploadedUrls.length; i++) {
        print('   ${i + 1}. ${uploadedUrls[i]}');
      }
    }
    
    print('============================================================\n');
    
    return uploadedUrls;
  }
}