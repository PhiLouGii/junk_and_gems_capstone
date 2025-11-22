class ProductHelper {
  static Map<String, String> convertToDisplayFormat(dynamic product) {
    // Handle image URLs
    String imageUrl = '';
    if (product['image_data_base64'] != null && 
        product['image_data_base64'] is List &&
        (product['image_data_base64'] as List).isNotEmpty) {
      imageUrl = product['image_data_base64'][0];
    } else if (product['image_url'] != null) {
      imageUrl = product['image_url'].toString();
    } else if (product['image'] != null) {
      imageUrl = product['image'].toString();
    }

    return {
      'id': product['id']?.toString() ?? '',
      'title': product['title']?.toString() ?? '',
      'price': product['price'] != null ? 'M${product['price']}' : 'M0',
      'image': imageUrl,
      'artisan': product['creator_name']?.toString() ?? 
                 product['artisan']?.toString() ?? 
                 'Unknown Artisan',
      'artisan_id': product['artisan_id']?.toString() ?? '',
      'description': product['description']?.toString() ?? '',
      
      // Additional fields
      'category': product['category']?.toString() ?? '',
      'condition': product['condition']?.toString() ?? '',
      'materials_used': product['materials_used']?.toString() ?? '',
      'dimensions': product['dimensions']?.toString() ?? '',
      
      // Location fields
      'location': product['location']?.toString() ?? '',
      'location_area': product['location_area']?.toString() ?? '',
      'location_landmark': product['location_landmark']?.toString() ?? '',
      'location_directions': product['location_directions']?.toString() ?? '',
      'latitude': product['latitude']?.toString() ?? '',
      'longitude': product['longitude']?.toString() ?? '',
      'map_address': product['map_address']?.toString() ?? '',
      'is_map_location': product['is_map_location']?.toString() ?? 'false',
      
      // Setup required
      'setup_required': product['setup_required']?.toString() ?? 'false',
    };
  }
}