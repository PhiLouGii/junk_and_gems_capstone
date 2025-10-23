import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';
import 'package:junk_and_gems/services/material_service.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'browse_materials_screen.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

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
  final Map<String, bool> _contactPreferences = {
    'In-app Chat': false,
    'Phone': false,
    'Email': false,
  };

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isAuthInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  // 🔥 NEW: Initialize Auth Provider on Screen Load
  Future<void> _initializeAuth() async {
    print('🔐 Initializing auth in CreateListingScreen...');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if already initialized
    if (authProvider.isInitialized) {
      print('✅ Auth already initialized');
      print('   User: ${authProvider.user?.name}');
      print('   User ID: ${authProvider.user?.id}');
      print('   Is Authenticated: ${authProvider.isAuthenticated}');
      setState(() {
        _isAuthInitialized = true;
      });
      return;
    }
    
    // Initialize auth provider
    print('⏳ Waiting for auth provider to initialize...');
    await authProvider.initialize();
    
    print('✅ Auth initialization complete');
    print('   User: ${authProvider.user?.name}');
    print('   User ID: ${authProvider.user?.id}');
    print('   Is Authenticated: ${authProvider.isAuthenticated}');
    
    if (mounted) {
      setState(() {
        _isAuthInitialized = true;
      });
    }
    
    // If still not authenticated after initialization, show warning
    if (!authProvider.isAuthenticated) {
      print('⚠️ User not authenticated after initialization');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Please log in to create a listing'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
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
          'Share the Goods',
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
          hintText: 'e.g., slabs of wood'
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
        _buildTextField(
          label: 'Location', 
          controller: _locationController, 
          hintText: 'Maseru West, Lesotho'
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
    return ImageUploadWidget(
      onImagesChanged: (images) {
        setState(() => _images = images);
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
            : const Text('Submit Listing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // 🔥 IMPROVED: Enhanced Submit with Better Auth Checking
  Future<void> _submitListing() async {
    // Validate required fields
    if (_titleController.text.isEmpty || 
        _descriptionController.text.isEmpty || 
        _selectedCategory == null || 
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Get the logged-in user's ID from auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 🔥 ENHANCED DEBUG LOGGING
    print('=' * 60);
    print('🔐 AUTH CHECK IN SUBMIT LISTING');
    print('Is Authenticated: ${authProvider.isAuthenticated}');
    print('Is Initialized: ${authProvider.isInitialized}');
    print('User object: ${authProvider.user}');
    print('User ID: ${authProvider.user?.id}');
    print('User name: ${authProvider.user?.name}');
    print('=' * 60);
    
    // 🔥 IMPROVED: Try to restore session from SharedPreferences if not authenticated
    if (!authProvider.isAuthenticated || authProvider.user?.id == null) {
      print('⚠️ User not authenticated, attempting to restore session...');
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final userId = prefs.getInt('userId');
        final userName = prefs.getString('userName');
        final userEmail = prefs.getString('userEmail');
        
        print('📦 SharedPreferences check:');
        print('   Token: ${token != null ? "EXISTS (${token.substring(0, 20)}...)" : "NULL"}');
        print('   User ID: $userId');
        print('   User Name: $userName');
        print('   User Email: $userEmail');
        
        if (token != null && userId != null) {
          print('✅ Found stored credentials, re-initializing auth...');
          await authProvider.initialize();
          
          // Check again after initialization
          if (authProvider.isAuthenticated && authProvider.user?.id != null) {
            print('✅ Auth restored successfully!');
            print('   User: ${authProvider.user?.name}');
            print('   User ID: ${authProvider.user?.id}');
          } else {
            print('❌ Auth restoration failed');
            _showLoginError();
            return;
          }
        } else {
          print('❌ No stored credentials found');
          _showLoginError();
          return;
        }
      } catch (e) {
        print('❌ Error restoring session: $e');
        _showLoginError();
        return;
      }
    }
    
    final int? uploaderId = authProvider.user?.id;
    
    if (uploaderId == null) {
      print('❌ Uploader ID is still null after all checks');
      _showLoginError();
      return;
    }
    
    print('✅ Proceeding with uploader ID: $uploaderId (${authProvider.user!.name})');
    print('=' * 60);

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('Starting material creation process...');

      // Ensure contact preferences are properly formatted
      Map<String, bool> formattedContactPrefs = {};
      _contactPreferences.forEach((key, value) {
        formattedContactPrefs[key] = value ?? false;
      });

      // Prepare the material data
      final materialData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory!,
        'quantity': _quantityController.text.isNotEmpty ? _quantityController.text : 'Not specified',
        'location': _locationController.text,
        'delivery_option': _selectedDeliveryOption ?? 'Needs Pickup',
        'available_from': _availableFrom?.toIso8601String(),
        'available_until': _availableUntil?.toIso8601String(),
        'is_fragile': _isFragile,
        'contact_preferences': formattedContactPrefs,
        'uploader_id': uploaderId,
      };

      print('Material data prepared: $materialData');

      // Create the material using the service
      bool success = await MaterialService.createMaterial(materialData, _images);

      if (success) {
        // Show success dialog
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
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Return to previous screen
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

  // 🔥 NEW: Helper method to show login error
  void _showLoginError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Please log in to create a listing'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'LOGIN',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Add navigation to login screen here
              // Navigator.pushNamed(context, '/login');
            },
          ),
        ),
      );
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

// Image Upload Widget (unchanged)
class ImageUploadWidget extends StatefulWidget {
  final Function(List<XFile>) onImagesChanged;
  const ImageUploadWidget({super.key, required this.onImagesChanged});

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  Future<void> _pickImages() async {
    try {
      print('📸 Opening image picker...');
      
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
      final Directory appDir = await getTemporaryDirectory();
      final String targetDir = '${appDir.path}/material_images';
      
      await Directory(targetDir).create(recursive: true);

      for (int i = 0; i < pickedFiles.length; i++) {
        try {
          final XFile pickedFile = pickedFiles[i];
          print('Processing image ${i + 1}/${pickedFiles.length}...');
          
          final File sourceFile = File(pickedFile.path);
          if (!await sourceFile.exists()) {
            print('⚠️ Source file does not exist: ${pickedFile.path}');
            continue;
          }

          final fileBytes = await sourceFile.readAsBytes();
          if (fileBytes.isEmpty) {
            print('⚠️ File is empty: ${pickedFile.path}');
            continue;
          }

          print('   File size: ${fileBytes.length} bytes');

          final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          final String extension = path.extension(pickedFile.path);
          final String fileName = 'material_${timestamp}_$i$extension';
          final String targetPath = '$targetDir/$fileName';

          final File targetFile = File(targetPath);
          await targetFile.writeAsBytes(fileBytes);
          
          print('   ✅ Saved to: $targetPath');

          copiedImages.add(XFile(targetPath));

        } catch (e) {
          print('❌ Error processing image ${i + 1}: $e');
        }
      }

      if (copiedImages.isEmpty) {
        if (mounted) {
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
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Maximum 5 images allowed. Added $availableSlots images.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          _images.addAll(copiedImages);
          
          if (mounted) {
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
      
      if (mounted) {
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

      setState(() {
        if (_images.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 5 images allowed'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          _images.add(XFile(targetPath));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo added'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });

      widget.onImagesChanged(_images);

    } catch (e) {
      print('❌ Camera error: $e');
      
      if (mounted) {
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
          'Upload images (up to 5) - Optional',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Theme.of(context).textTheme.bodyLarge?.color
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
              border: Border.all(color: const Color(0xFFBEC092), width: 1)
            ),
            child: _images.isEmpty
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
        if (_images.isNotEmpty)
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

  @override
  void dispose() {
    super.dispose();
  }
}