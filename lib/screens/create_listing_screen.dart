import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';
import 'package:junk_and_gems/services/material_service.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/screens/browse_materials_screen.dart';
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

class CreateListingScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? existingMaterial;
  
  const CreateListingScreen({
    super.key, 
    this.isEditing = false,
    this.existingMaterial,
  });

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  String? _selectedCategory;
  String? _selectedDeliveryOption;
  DateTime? _availableFrom;
  DateTime? _availableUntil;
  bool _isFragile = false;
  List<XFile> _images = [];
  Map<String, String> _locationData = {};
  final Map<String, bool> _contactPreferences = {
    'In-app Chat': false,
    'Phone': false,
    'Email': false,
  };

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isAuthInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth().then((_) {
      _debugPrintStoredData();
      _loadExistingMaterial();
    });
  }

  void _loadExistingMaterial() {
  if (!widget.isEditing || widget.existingMaterial == null) return;
  
  final material = widget.existingMaterial!;
  
  _titleController.text = material['title'] ?? '';
  _descriptionController.text = material['description'] ?? '';
  _selectedCategory = material['category'];
  _quantityController.text = material['quantity'] ?? '';
  _selectedDeliveryOption = material['delivery_option'] ?? 'Needs Pickup';
  _isFragile = material['is_fragile'] ?? false;
  
  // Load location data
  if (material['location'] != null) {
    _locationData = {
      'formatted': material['location'],
      'area': material['location_area'] ?? '',
      'landmark': material['location_landmark'] ?? '',
      'directions': material['location_directions'] ?? '',
    };
  }
  
  // Load dates
  if (material['available_from'] != null) {
    try {
      _availableFrom = DateTime.parse(material['available_from']);
    } catch (e) {
      print('Error parsing available_from: $e');
    }
  }
  
  if (material['available_until'] != null) {
    try {
      _availableUntil = DateTime.parse(material['available_until']);
    } catch (e) {
      print('Error parsing available_until: $e');
    }
  }
  
  // Load contact preferences
  if (material['contact_preferences'] != null) {
    final prefs = material['contact_preferences'] as Map<String, dynamic>;
    prefs.forEach((key, value) {
      if (_contactPreferences.containsKey(key)) {
        _contactPreferences[key] = value == true;
      }
    });
  }
  
  setState(() {});
}

  // Initialize Auth Provider
  Future<void> _initializeAuth() async {
    print('Initializing auth in CreateListingScreen...');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    //ALWAYS re-initialize to get latest user data
    print('Re-initializing auth provider...');
    await authProvider.initialize();
    
    print('Auth initialization complete');
    print('   User: ${authProvider.user?.name}');
    print('   User ID: ${authProvider.user?.id}');
    print('   Is Authenticated: ${authProvider.isAuthenticated}');
    
    if (mounted) {
      setState(() {
        _isAuthInitialized = true;
      });
    }
    
    if (!authProvider.isAuthenticated) {
      print('User not authenticated after initialization');
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !authProvider.isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please log in to create a listing'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      }
    } else {
      print('User authenticated successfully: ${authProvider.user?.name}');
    }
  }

  // Debug method
  Future<void> _debugPrintStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('');
    print('=' * 80);
    print('STORED DATA CHECK IN CREATE LISTING SCREEN');
    print('=' * 80);
    print('SharedPreferences:');
    print('  All Keys: ${prefs.getKeys()}');
    print('  user_data: ${prefs.getString('user_data')}');
    print('  userId: ${prefs.get('userId')}');
    print('  userName: ${prefs.getString('userName')}');
    print('');
    print('AuthProvider:');
    print('  Is Initialized: ${authProvider.isInitialized}');
    print('  Is Authenticated: ${authProvider.isAuthenticated}');
    print('  User: ${authProvider.user?.name}');
    print('  User ID: ${authProvider.user?.id}');
    print('=' * 80);
    print('');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    //Show loading while auth initializes
    if (!_isAuthInitialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: const Color(0xFF88844D)),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildCreateListing1(),
              const SizedBox(height: 32),
              _buildCreateListing2(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
  return Row(
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
        onPressed: () => Navigator.pop(context),
      ),
        Image.asset('assets/images/logo.png', width: 60, height: 60),
      const SizedBox(width: 12),
      Text(
        widget.isEditing ? 'Edit Material' : 'Share the Goods', // ✅ CHANGE THIS
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    ],
  );
}

  Widget _buildCreateListing1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Listing',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: 'Waste Title/Name', 
          controller: _titleController, 
          hintText: 'e.g., Slabs of wood'
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Description',
          controller: _descriptionController,
          hintText: 'Describe the condition, quantity, material type, etc...',
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        _buildImageUpload(),
        const SizedBox(height: 20),
        _buildDropdown(
          label: 'Category/Material Type',
          hintText: 'Select a category',
          value: _selectedCategory,
          items: const ['Plastic', 'Fabric', 'Glass', 'Metal', 'Wood', 'Electronics', 'Other'],
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Quantity/Weight', 
          controller: _quantityController, 
          hintText: 'e.g., 5 items or 1kg'
        ),
        const SizedBox(height: 20),
        StructuredLocationWidget(
          onLocationChanged: (locationData) {
            setState(() {
              _locationData = locationData;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCreateListing2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup/Drop-off Option', 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDeliveryOption('Donor can deliver', 'Donor can deliver')),
            const SizedBox(width: 16),
            Expanded(child: _buildDeliveryOption('Needs Pickup', 'Needs Pickup')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Available From',
                hintText: 'dd/mm/yyyy',
                date: _availableFrom,
                onTap: () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'Available Until',
                hintText: 'dd/mm/yyyy',
                date: _availableUntil,
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: const Color(0xFFBEC092), width: 1)
          ),
          child: CheckboxListTile(
            title: Text(
              'Fragile', 
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )
            ),
            value: _isFragile,
            onChanged: (value) => setState(() => _isFragile = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Contact Preferences', 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        const SizedBox(height: 12),
        Column(
          children: _contactPreferences.keys.map((preference) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: const Color(0xFFBEC092), width: 1)
                ),
                child: CheckboxListTile(
                  title: Text(
                    preference, 
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )
                  ),
                  value: _contactPreferences[preference],
                  onChanged: (value) => setState(() => _contactPreferences[preference] = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hintText, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: const Color(0xFFBEC092), width: 1)
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
  print('Building image upload widget with ${_images.length} images');
  return ImageUploadWidget(
    images: _images,
    onImagesChanged: (images) {
      print('Images changed callback: ${images.length} images');
      setState(() {
        _images = images;
      });
      print('State updated with ${_images.length} images');
    },
  );
}

  Widget _buildDropdown({required String label, required String hintText, required String? value, required List<String> items, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: const Color(0xFFBEC092), width: 1)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hintText, 
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))
              ),
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).cardColor,
              items: items.map((item) => DropdownMenuItem(
                value: item, 
                child: Text(
                  item, 
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)
                )
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(String value, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedDeliveryOption = value),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _selectedDeliveryOption == value ? const Color(0xFFBEC092) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBEC092), width: 2),
        ),
        child: Center(
          child: Text(
            label, 
            style: TextStyle(
              color: _selectedDeliveryOption == value ? const Color(0xFF88844D) : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600
            )
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({required String label, required String hintText, required DateTime? date, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: const Color(0xFFBEC092), width: 1)
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    date != null ? '${date.day}/${date.month}/${date.year}' : hintText, 
                    style: TextStyle(
                      color: date != null 
                        ? Theme.of(context).textTheme.bodyLarge?.color 
                        : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                    )
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today, 
                    size: 20, 
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitListing,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF88844D),
          foregroundColor: const Color(0xFFF7F2E4),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF7F2E4)),
                ),
              )
            : Text(
                widget.isEditing ? 'Update Material' : 'Submit Listing', // ✅ CHANGE THIS
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  //Submit with proper user ID retrieval
  Future<void> _submitListing() async {
    if (_titleController.text.isEmpty || 
        _descriptionController.text.isEmpty || 
        _selectedCategory == null || 
        (_locationData['area'] == null || _locationData['area']!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields including location')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('=' * 80);
    print('🔍 CRITICAL AUTH CHECK - GETTING USER ID');
    print('=' * 80);
    
    int? uploaderId;
    String? uploaderName;
    String? uploaderEmail;
    
    // Method 1: Try user_data JSON
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      try {
        final userData = json.decode(userDataStr);
        uploaderId = userData['id'];
        uploaderName = userData['name'];
        uploaderEmail = userData['email'];
        print('✅ Got user from user_data JSON:');
        print('   ID: $uploaderId, Name: $uploaderName');
      } catch (e) {
        print('⚠️ Failed to parse user_data: $e');
      }
    }
    
    // Method 2: Try individual keys (fallback)
    if (uploaderId == null) {
      final userIdValue = prefs.get('userId');
      if (userIdValue is int) {
        uploaderId = userIdValue;
      } else if (userIdValue is String) {
        uploaderId = int.tryParse(userIdValue);
      }
      uploaderName = prefs.getString('userName');
      uploaderEmail = prefs.getString('userEmail');
      
      if (uploaderId != null) {
        print('✅ Got user from individual keys:');
        print('   ID: $uploaderId, Name: $uploaderName');
      }
    }
    
    // Method 3: Try AuthProvider (last resort)
    if (uploaderId == null) {
      uploaderId = authProvider.user?.id;
      uploaderName = authProvider.user?.name;
      uploaderEmail = authProvider.user?.email;
      
      if (uploaderId != null) {
        print('Got user from AuthProvider:');
        print('   ID: $uploaderId, Name: $uploaderName');
      }
    }
    
    print('');
    print('Final User Data:');
    print('   Uploader ID: $uploaderId (type: ${uploaderId.runtimeType})');
    print('   Uploader Name: $uploaderName');
    print('   Uploader Email: $uploaderEmail');
    print('');
    print('All SharedPreferences Keys: ${prefs.getKeys()}');
    print('=' * 80);
    
    // Final validation
    if (uploaderId == null) {
      print('CRITICAL: Could not get user ID from any source!');
      print('   Checked user_data: ${prefs.getString('user_data')}');
      print('   Checked userId: ${prefs.get('userId')}');
      print('   Checked AuthProvider: ${authProvider.user?.id}');
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Authentication Error'),
            content: Text(
              'Could not find logged-in user data. Please log in again.\n\n'
              'Debug Info:\n'
              '- user_data exists: ${prefs.getString('user_data') != null}\n'
              '- userId exists: ${prefs.get('userId') != null}\n'
              '- AuthProvider user: ${authProvider.user?.name ?? 'null'}'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }
    
    print('Proceeding with uploader ID: $uploaderId ($uploaderName)');
    print('=' * 80);

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('Starting material creation process...');

      Map<String, bool> formattedContactPrefs = {};
      _contactPreferences.forEach((key, value) {
        formattedContactPrefs[key] = value ?? false;
      });

      final materialData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory!,
        'quantity': _quantityController.text.isNotEmpty ? _quantityController.text : 'Not specified',
        'delivery_option': _selectedDeliveryOption ?? 'Needs Pickup',
        'available_from': _availableFrom?.toIso8601String(),
        'available_until': _availableUntil?.toIso8601String(),
        'is_fragile': _isFragile,
        'contact_preferences': formattedContactPrefs,
        'uploader_id': uploaderId,
        'location': _locationData['formatted'] ?? '',
        'location_area': _locationData['area'] ?? '',
        'location_landmark': _locationData['landmark'] ?? '',
        'location_directions': _locationData['directions'] ?? '',
        'latitude': _locationData['latitude'],
        'longitude': _locationData['longitude'],
        'map_address': _locationData['map_address'],
        'is_map_location': _locationData['is_map_location'],
      };

      print('Material data prepared: $materialData');

      bool success;
      if (widget.isEditing && widget.existingMaterial != null) {
        // Use MaterialService to handle images properly
        success = await MaterialService.updateMaterial(
          widget.existingMaterial!['id'].toString(),
          materialData,
          _images, 
        );
      } else {
        // Already working
        print('About to submit:');
        print('   Total images: ${_images.length}');
        for (int i = 0; i < _images.length; i++) {
          final file = File(_images[i].path);
          final exists = await file.exists();
          final size = exists ? await file.length() : 0;
          print('   Image $i: ${_images[i].path}');
          print('      Exists: $exists');
          print('      Size: ${(size / 1024).toStringAsFixed(2)} KB');
        }
        success = await MaterialService.createMaterial(materialData, _images);
      }

      if (success) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Good work!', 
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close, 
                      color: Theme.of(context).textTheme.bodyLarge?.color
                    ),
                  ),
                ],
              ),
              content: Text(
                'Your waste will soon find a new purpose!', 
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'OK', 
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Detailed error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime.now(), 
      lastDate: DateTime(2100)
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _availableFrom = picked;
        } else {
          _availableUntil = picked;
        }
      });
    }
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, false, onTap: () => Navigator.pop(context)),
          _navItem(Icons.inventory_2_outlined, true),
          _navItem(Icons.shopping_bag_outlined, false),
          _navItem(Icons.notifications_active_outlined, false),
          _navItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isSelected 
            ? BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF2A2A2A) 
                    : const Color(0xFFF7F2E4), 
                shape: BoxShape.circle
              ) 
            : null,
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon, 
          color: isSelected 
              ? const Color(0xFF88844D) 
              : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6), 
          size: 28
        ),
      ),
    );
  }
}

// Image Upload Widget
class ImageUploadWidget extends StatelessWidget {
  final List<XFile> images;
  final Function(List<XFile>) onImagesChanged;
  
  const ImageUploadWidget({
    super.key,
    required this.images,
    required this.onImagesChanged,
  });

  Future<void> _pickImages(BuildContext context) async {
  try {
    final ImagePicker picker = ImagePicker();
    print('📸 Opening image picker...');
    
    final List<XFile> pickedFiles = await picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    
    if (pickedFiles.isEmpty) {
      print('❌ No images selected');
      return;
    }

    print('✓ Selected ${pickedFiles.length} images');

    List<XFile> copiedImages = [];
    final Directory appDir = await getTemporaryDirectory();
    final String targetDir = '${appDir.path}/material_images';
    
    // Ensure directory exists
    final Directory dir = Directory(targetDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    for (int i = 0; i < pickedFiles.length; i++) {
      try {
        final XFile pickedFile = pickedFiles[i];
        print('📁 Processing image ${i + 1}/${pickedFiles.length}...');
        print('   Original path: ${pickedFile.path}');
        
        // ✅ FIX: Read bytes directly from XFile (works for both gallery and camera)
        final Uint8List fileBytes = await pickedFile.readAsBytes();
        
        if (fileBytes.isEmpty) {
          print('   ⚠️ File is empty, skipping');
          continue;
        }

        print('   ✓ Read ${fileBytes.length} bytes (${(fileBytes.length / 1024).toStringAsFixed(2)} KB)');

        // Generate unique filename
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String extension = path.extension(pickedFile.path).isEmpty 
            ? '.jpg' 
            : path.extension(pickedFile.path);
        final String fileName = 'material_${timestamp}_$i$extension';
        final String targetPath = '$targetDir/$fileName';

        // Write to our controlled location
        final File targetFile = File(targetPath);
        await targetFile.writeAsBytes(fileBytes, flush: true);
        
        // Verify the file was written
        if (await targetFile.exists()) {
          final verifySize = await targetFile.length();
          print('   ✅ Saved to: $targetPath');
          print('   ✅ Verified size: ${(verifySize / 1024).toStringAsFixed(2)} KB');
          
          copiedImages.add(XFile(targetPath));
        } else {
          print('   ❌ Failed to verify saved file');
        }

      } catch (e) {
        print('❌ Error processing image ${i + 1}: $e');
        print('   Stack: ${StackTrace.current}');
      }
    }

    if (copiedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process selected images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('📊 Successfully processed ${copiedImages.length}/${pickedFiles.length} images');

    List<XFile> newImages = List.from(images);
    
    if (newImages.length + copiedImages.length > 5) {
      int availableSlots = 5 - newImages.length;
      newImages.addAll(copiedImages.take(availableSlots));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 5 images allowed. Added $availableSlots images.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      newImages.addAll(copiedImages);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${copiedImages.length} image(s)'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    print('📊 Total images now: ${newImages.length}');
    onImagesChanged(newImages);

  } catch (e) {
    print('❌ Image picker error: $e');
    print('Stack: ${StackTrace.current}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error selecting images: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

  Future<void> _takePhoto(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      print('📷 Opening camera...');
      
      final XFile? photo = await picker.pickImage(
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

      final Directory appDir = await getTemporaryDirectory();
      final String targetDir = '${appDir.path}/material_images';
      await Directory(targetDir).create(recursive: true);

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(photo.path);
      final String fileName = 'material_camera_$timestamp$extension';
      final String targetPath = '$targetDir/$fileName';

      final File sourceFile = File(photo.path);
      final fileBytes = await sourceFile.readAsBytes();
      await File(targetPath).writeAsBytes(fileBytes);

      print('   ✅ Saved to: $targetPath');

      if (images.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 5 images allowed'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        List<XFile> newImages = List.from(images);
        newImages.add(XFile(targetPath));
        onImagesChanged(newImages);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      print('❌ Camera error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceOptions(BuildContext context) {
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
                    _pickImages(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF88844D)),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(context);
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
          'Upload images (up to 5) - Optional',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: images.length < 5 ? () => _showImageSourceOptions(context) : null,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: const Color(0xFFBEC092), width: 1)
            ),
            child: images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined, 
                          size: 40, 
                          color: Theme.of(context).textTheme.bodyLarge?.color
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add images', 
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color, 
                            fontSize: 14
                          )
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
                    itemCount: images.length + (images.length < 5 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == images.length) {
                        return GestureDetector(
                          onTap: () => _showImageSourceOptions(context),
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
                                image: FileImage(File(images[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () {
                                List<XFile> newImages = List.from(images);
                                newImages.removeAt(index);
                                onImagesChanged(newImages);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Image removed'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
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
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'First image will be the main photo',
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
}