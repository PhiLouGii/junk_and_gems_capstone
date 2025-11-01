import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/services/product_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:junk_and_gems/widgets/map_location_picker.dart';

class StructuredLocationWidget extends StatefulWidget {
  final Function(Map<String, String>) onLocationChanged;
  final Map<String, String>? initialLocation;

  const StructuredLocationWidget({
    super.key,
    required this.onLocationChanged,
    this.initialLocation,
  });

  @override
  State<StructuredLocationWidget> createState() => _StructuredLocationWidgetState();
}

class _StructuredLocationWidgetState extends State<StructuredLocationWidget> {
  String? _selectedArea;
  final _landmarkController = TextEditingController();
  final _directionsController = TextEditingController();
  final _customAreaController = TextEditingController();
  bool _isCustomArea = false;
  
  // Map location data
  double? _latitude;
  double? _longitude;
  String? _mapAddress;
  bool _isUsingMapLocation = false;

  final List<String> _areas = [
    'Thetsane',
    'Lithabaneng',
    'Katlehong',
    'Ha Tšosane',
    'Maseru West',
    'Ha Matala',
    'Masowe',
    'Ha Thetsane',
    'Pioneer Mall',
    'Maseru Mall',
    'Kick4Life Centre',
    'NRH Mall',
    'Setsoto Stadium',
    'Custom Location...',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedArea = widget.initialLocation!['area'];
      _landmarkController.text = widget.initialLocation!['landmark'] ?? '';
      _directionsController.text = widget.initialLocation!['directions'] ?? '';
      
      // Load map coordinates if available
      if (widget.initialLocation!['latitude'] != null) {
        _latitude = double.tryParse(widget.initialLocation!['latitude'] ?? '');
        _longitude = double.tryParse(widget.initialLocation!['longitude'] ?? '');
        _mapAddress = widget.initialLocation!['map_address'];
        _isUsingMapLocation = _latitude != null && _longitude != null;
      }
      
      if (_selectedArea != null && !_areas.contains(_selectedArea)) {
        _isCustomArea = true;
        _customAreaController.text = _selectedArea!;
        _selectedArea = 'Custom Location...';
      }
    }
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    _directionsController.dispose();
    _customAreaController.dispose();
    super.dispose();
  }

  void _notifyLocationChange() {
    final area = _isCustomArea ? _customAreaController.text : _selectedArea;
    
    final locationData = {
      'area': area ?? '',
      'landmark': _landmarkController.text,
      'directions': _directionsController.text,
      'formatted': _formatLocation(),
      // Include map coordinates if available
      'latitude': _latitude?.toString() ?? '',
      'longitude': _longitude?.toString() ?? '',
      'map_address': _mapAddress ?? '',
      'is_map_location': _isUsingMapLocation.toString(),
    };
    
    widget.onLocationChanged(locationData);
  }

  String _formatLocation() {
    if (_isUsingMapLocation && _mapAddress != null) {
      return _mapAddress!;
    }
    
    List<String> parts = [];
    
    final area = _isCustomArea ? _customAreaController.text : _selectedArea;
    if (area != null && area.isNotEmpty && area != 'Custom Location...') {
      parts.add(area);
    }
    
    if (_landmarkController.text.isNotEmpty) {
      parts.add(_landmarkController.text);
    }
    
    if (_directionsController.text.isNotEmpty) {
      parts.add(_directionsController.text);
    }
    
    return parts.join(' • ');
  }

  Future<void> _openMapPicker() async {
    LatLng? initialLocation;
    if (_latitude != null && _longitude != null) {
      initialLocation = LatLng(_latitude!, _longitude!);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          onLocationSelected: (locationData) {
            setState(() {
              _latitude = locationData['latitude'];
              _longitude = locationData['longitude'];
              _mapAddress = locationData['address'];
              _isUsingMapLocation = true;
              
              // Auto-fill area if nearest area was found
              if (locationData['nearest_area'] != null) {
                final nearestArea = locationData['nearest_area'] as String;
                if (_areas.contains(nearestArea)) {
                  _selectedArea = nearestArea;
                  _isCustomArea = false;
                }
              }
            });
            _notifyLocationChange();
          },
          initialLocation: initialLocation,
        ),
      ),
    );
  }

  void _clearMapLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _mapAddress = null;
      _isUsingMapLocation = false;
    });
    _notifyLocationChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Location *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            TextButton.icon(
              onPressed: _openMapPicker,
              icon: const Icon(Icons.map, size: 18, color: Color(0xFF88844D)),
              label: const Text(
                'Pick on Map',
                style: TextStyle(color: Color(0xFF88844D)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Show map location if selected
        if (_isUsingMapLocation && _mapAddress != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF88844D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF88844D), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF88844D), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Map Location Selected',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _clearMapLocation,
                      tooltip: 'Clear map location',
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _mapAddress!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coordinates: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '- OR -',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Structured form fields
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBEC092), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _selectedArea,
              hint: Row(
                children: [
                  const Icon(Icons.location_city, color: Color(0xFF88844D), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Select Area / Neighborhood',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).cardColor,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF88844D)),
              items: _areas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Row(
                    children: [
                      Icon(
                        area == 'Custom Location...' 
                            ? Icons.add_location_alt 
                            : Icons.location_on,
                        color: const Color(0xFF88844D),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        area,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: area == 'Custom Location...' 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedArea = value;
                  _isCustomArea = value == 'Custom Location...';
                  if (!_isCustomArea) {
                    _customAreaController.clear();
                  }
                  // Clear map location when using form
                  if (!_isCustomArea) {
                    _isUsingMapLocation = false;
                  }
                });
                _notifyLocationChange();
              },
            ),
          ),
        ),
        
        if (_isCustomArea) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBEC092), width: 1),
            ),
            child: TextField(
              controller: _customAreaController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Enter your area name',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: const Icon(Icons.edit_location_alt, color: Color(0xFF88844D)),
              ),
              onChanged: (_) => _notifyLocationChange(),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBEC092), width: 1),
          ),
          child: TextField(
            controller: _landmarkController,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Landmark or Street (e.g., Next to Shell Garage)',
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: const Icon(Icons.place, color: Color(0xFF88844D)),
            ),
            onChanged: (_) => _notifyLocationChange(),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBEC092), width: 1),
          ),
          child: TextField(
            controller: _directionsController,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Extra Directions (e.g., Blue gate, behind big tree)',
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(Icons.directions, color: Color(0xFF88844D)),
              ),
            ),
            onChanged: (_) => _notifyLocationChange(),
          ),
        ),
        
        if (_formatLocation().isNotEmpty && !_isUsingMapLocation) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBEC092).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF88844D),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location: ${_formatLocation()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class ImageUploadWidget extends StatefulWidget {
  final Function(List<XFile>) onImagesChanged;
  const ImageUploadWidget({super.key, required this.onImagesChanged});

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
  try {
    print('Opening image picker...');
    
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    
    if (pickedFiles.isEmpty) {
      print('No images selected');
      return;
    }

    print('Selected ${pickedFiles.length} images');

    List<XFile> copiedImages = [];
    final Directory appDir = await getApplicationDocumentsDirectory(); // ✅ FIXED
    final String targetDir = '${appDir.path}/product_images';
    
    await Directory(targetDir).create(recursive: true);

    for (int i = 0; i < pickedFiles.length; i++) {
      try {
        final XFile pickedFile = pickedFiles[i];
        print('Processing image ${i + 1}/${pickedFiles.length}...');
        
        // Read bytes directly from XFile
        final fileBytes = await pickedFile.readAsBytes();
        
        if (fileBytes.isEmpty) {
          print('⚠️ File is empty, skipping');
          continue;
        }

        print('   File size: ${(fileBytes.length / 1024).toStringAsFixed(2)} KB');

        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String extension = path.extension(pickedFile.path).isEmpty 
            ? '.jpg' 
            : path.extension(pickedFile.path);
        final String fileName = 'product_${timestamp}_$i$extension';
        final String targetPath = '$targetDir/$fileName';

        final File targetFile = File(targetPath);
        await targetFile.writeAsBytes(fileBytes, flush: true);
        
        if (await targetFile.exists()) {
          print('   ✅ Saved to: $targetPath');
          copiedImages.add(XFile(targetPath));
        }

      } catch (e) {
        print('❌ Error processing image ${i + 1}: $e');
      }
    }

    if (copiedImages.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process selected images'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      if (_images.length + copiedImages.length > 5) {
        int availableSlots = 5 - _images.length;
        _images.addAll(copiedImages.take(availableSlots));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 5 images allowed. Added $availableSlots images.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        _images.addAll(copiedImages);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${copiedImages.length} image(s)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
    
    print('📊 Total images now: ${_images.length}');
    widget.onImagesChanged(_images);

  } catch (e) {
    print('❌ Image picker error: $e');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting images: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

  Future<void> _takePhoto() async {
  try {
    print('📷 Opening camera...');
    
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (photo == null) {
      print('❌ No photo taken');
      return;
    }

    print('✅ Photo captured: ${photo.path}');

    final Directory appDir = await getApplicationDocumentsDirectory(); // ✅ FIXED
    final String targetDir = '${appDir.path}/product_images';
    await Directory(targetDir).create(recursive: true);

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = path.extension(photo.path);
    final String fileName = 'product_camera_$timestamp$extension';
    final String targetPath = '$targetDir/$fileName';

    final fileBytes = await photo.readAsBytes();
    await File(targetPath).writeAsBytes(fileBytes);

    print('   ✅ Saved to: $targetPath');

    setState(() {
      if (_images.length >= 5) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 5 images allowed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        _images.add(XFile(targetPath));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo added'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });

    widget.onImagesChanged(_images);

  } catch (e) {
    print('❌ Camera error: $e');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF88844D)),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF88844D)),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images * (${_images.length}/5)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _images.length < 5 ? _showImageSourceOptions : null,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBEC092), 
                width: 1
              ),
            ),
            child: _images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined, 
                          size: 40,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add product images',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gallery or Camera',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: _images.length + (_images.length < 5 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _images.length) {
                        return GestureDetector(
                          onTap: _showImageSourceOptions,
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBEC092).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFBEC092),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Color(0xFF88844D),
                              ),
                            ),
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(_images[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.removeAt(index);
                                  widget.onImagesChanged(_images);
                                });
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Image removed'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF88844D),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        if (_images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'First image will be the main product photo',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CreateProductListingScreen extends StatefulWidget {
  const CreateProductListingScreen({super.key});

  @override
  State<CreateProductListingScreen> createState() => _CreateProductListingScreenState();
}

class _CreateProductListingScreenState extends State<CreateProductListingScreen> {
  String? _selectedCategory;
  String? _selectedCondition;
  double _price = 0.0;
  List<XFile> _images = [];
  Map<String, String> _locationData = {}; // ✅ NEW: Location data storage
  bool _isSubmitting = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _materialsController = TextEditingController();
  final _dimensionsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _materialsController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sell Your Creation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreateListingForm(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateListingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Product Name *', _titleController, 'e.g., Bottle Cap Coaster Set'),
        const SizedBox(height: 20),
        _buildTextField(
          'Product Description *',
          _descriptionController,
          'Describe your upcycled creation...',
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        _buildImageUpload(),
        const SizedBox(height: 20),
        _buildDropdown(
          'Product Category *',
          'Select a category',
          _selectedCategory,
          const ['Home Decor', 'Furniture', 'Fashion', 'Jewelry', 'Art', 'Crafts', 'Other'],
          (value) => setState(() => _selectedCategory = value),
        ),
        const SizedBox(height: 20),
        _buildTextField('Original Materials Used', _materialsController, 'e.g., Denim, Wood scraps'),
        const SizedBox(height: 20),
        _buildTextField('Dimensions/Size', _dimensionsController, 'e.g., 12" height, 6" diameter'),
        const SizedBox(height: 20),
        _buildDropdown(
          'Condition *',
          'Select condition',
          _selectedCondition,
          const ['New', 'Like New', 'Excellent', 'Good', 'Fair'],
          (value) => setState(() => _selectedCondition = value),
        ),
        const SizedBox(height: 20),
        _buildPriceField(),
        const SizedBox(height: 20),
        // ✅ REPLACED: Old text field with StructuredLocationWidget
        StructuredLocationWidget(
          onLocationChanged: (locationData) {
            setState(() {
              _locationData = locationData;
            });
          },
        ),
        const SizedBox(height: 10),
        Text(
          '* Required fields',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hintText, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBEC092), width: 1),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String label, String hintText, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBEC092), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hintText,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).cardColor,
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price *',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBEC092), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('M',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    onChanged: (value) => setState(() {
                      _price = double.tryParse(value) ?? 0.0;
                    }),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return ImageUploadWidget(
      onImagesChanged: (images) {
        setState(() {
          _images = images;
        });
        print('📸 Images updated: ${images.length} images selected');
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBEC092),
          foregroundColor: const Color(0xFF88844D),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF88844D)),
                ),
              )
            : const Text('List Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _submitProduct() async {
    print('🚀 Starting product submission...');
    
    // Validation
    if (_titleController.text.isEmpty) {
      return _showErrorDialog('Please enter a product name');
    }
    if (_descriptionController.text.isEmpty) {
      return _showErrorDialog('Please enter a product description');
    }
    if (_selectedCategory == null) {
      return _showErrorDialog('Please select a product category');
    }
    if (_selectedCondition == null) {
      return _showErrorDialog('Please select the product condition');
    }
    if (_price <= 0) {
      return _showErrorDialog('Please enter a valid price');
    }
    if (_images.isEmpty) {
      return _showErrorDialog('Please select at least one image');
    }
    // ✅ NEW: Validate location
    if (_locationData['area'] == null || _locationData['area']!.isEmpty) {
      return _showErrorDialog('Please select a location');
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final userName = prefs.getString('userName') ?? 'Unknown User';
      
      if (userId == null) {
        setState(() => _isSubmitting = false);
        return _showErrorDialog('Please login to list a product');
      }

      print('👤 User ID: $userId');
      print('👤 User Name: $userName');
      print('📸 Images to upload: ${_images.length}');
      print('📍 Location: ${_locationData['formatted']}');

      // Show progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF88844D)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Uploading images...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a minute on mobile',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      // ✅ UPDATED: Prepare product data with structured location
      final productData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': _price,
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'materials_used': _materialsController.text.trim(),
        'dimensions': _dimensionsController.text.trim(),
        'location': _locationData['formatted'] ?? '',
        'location_area': _locationData['area'] ?? '',
        'location_landmark': _locationData['landmark'] ?? '',
        'location_directions': _locationData['directions'] ?? '',
        'artisan_id': userId,
        'creator_name': userName,
      };

      print('📦 Product data prepared');

      // Call ProductService to create product
      final success = await ProductService.createProduct(productData, _images);

      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        
        if (success) {
          _showSuccessDialog();
        } else {
          _showErrorDialog(
            'Failed to create product. Please check:\n'
            '• Your internet connection\n'
            '• Image sizes (try smaller images)\n'
            '• Network signal strength'
          );
        }
      }

    } catch (e) {
      print('❌ Error creating product: $e');
      
      if (mounted) {
        Navigator.pop(context); // Close progress dialog if open
        
        String errorMessage = 'Error: ${e.toString()}';
        
        // Provide helpful error messages
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Network')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('timeout') || 
                   e.toString().contains('Timeout')) {
          errorMessage = 'Upload timeout. Your connection may be slow. Try:\n'
                        '• Using fewer images\n'
                        '• Connecting to a faster network\n'
                        '• Trying again in a moment';
        }
        
        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Success!', style: TextStyle(color: Colors.green)),
        content: const Text('Your upcycled product has been listed successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to marketplace
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}