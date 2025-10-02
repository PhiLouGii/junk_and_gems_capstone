import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:junk_and_gems/services/material_service.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () => Navigator.pop(context),
        ),
        Image.asset('assets/images/logo.png', width: 60, height: 60),
        const SizedBox(width: 12),
        const Text(
          'Share the Goods',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateListing1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Listing',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF88844D)),
        ),
        const SizedBox(height: 24),
        _buildTextField(label: 'Waste Title/Name', controller: _titleController, hintText: 'e.g., slabs of wood'),
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
        _buildTextField(label: 'Quantity/Weight', controller: _quantityController, hintText: 'e.g., 5 items or 1kg'),
        const SizedBox(height: 20),
        _buildTextField(label: 'Location', controller: _locationController, hintText: 'Western West, Lesotho'),
      ],
    );
  }

  Widget _buildCreateListing2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pickup/Drop-off Option', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D))),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBEC092), width: 1)),
          child: CheckboxListTile(
            title: const Text('Fragile', style: TextStyle(fontWeight: FontWeight.w500)),
            value: _isFragile,
            onChanged: (value) => setState(() => _isFragile = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        const SizedBox(height: 20),
        const Text('Contact Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D))),
        const SizedBox(height: 12),
        Column(
          children: _contactPreferences.keys.map((preference) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBEC092), width: 1)),
                child: CheckboxListTile(
                  title: Text(preference, style: const TextStyle(fontWeight: FontWeight.w500)),
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
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBEC092), width: 1)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: const Color(0xFF88844D).withOpacity(0.6)),
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
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBEC092), width: 1)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: value,
              hint: Text(hintText, style: TextStyle(color: const Color(0xFF88844D).withOpacity(0.6))),
              isExpanded: true,
              underline: const SizedBox(),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Color(0xFF88844D))))).toList(),
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
          color: _selectedDeliveryOption == value ? const Color(0xFFBEC092) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBEC092), width: 2),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Color(0xFF88844D), fontWeight: FontWeight.w600))),
      ),
    );
  }

  Widget _buildDateField({required String label, required String hintText, required DateTime? date, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBEC092), width: 1)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(date != null ? '${date.day}/${date.month}/${date.year}' : hintText, style: TextStyle(color: date != null ? const Color(0xFF88844D) : const Color(0xFF88844D).withOpacity(0.6))),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 20, color: const Color(0xFF88844D).withOpacity(0.6)),
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
      onPressed: () async {
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

        try {
          // Convert XFile to File and upload images
          List<String> imageUrls = [];
          if (_images.isNotEmpty) {
            // Convert XFile to File
            List<File> imageFiles = _images.map((xFile) => File(xFile.path)).toList();
            imageUrls = await MaterialService.uploadMultipleImages(imageFiles);
          }

          // Prepare the material data
          final materialData = {
            'title': _titleController.text,
            'description': _descriptionController.text,
            'category': _selectedCategory!,
            'quantity': _quantityController.text,
            'location': _locationController.text,
            'delivery_option': _selectedDeliveryOption ?? '',
            'available_from': _availableFrom?.toIso8601String(),
            'available_until': _availableUntil?.toIso8601String(),
            'is_fragile': _isFragile,
            'contact_preferences': _contactPreferences,
            'image_urls': imageUrls,
            'uploader_id': 1, // Replace with actual user ID from auth
          };

          // Create the material
          await MaterialService.createMaterial(materialData);

          // Show success dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFFF7F2E4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Good work!', style: TextStyle(color: Color(0xFF88844D))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Color(0xFF88844D)),
                  ),
                ],
              ),
              content: const Text('Your waste will soon find a new purpose!', style: TextStyle(color: Color(0xFF88844D))),
            ),
          ).then((_) {
            Navigator.pop(context, true); // Return true to indicate success
          });

        } catch (e) {
          print('Error creating material: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating listing: $e')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF88844D),
        foregroundColor: const Color(0xFFF7F2E4),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Submit Listing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    ),
  );
}

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        if (isFromDate) _availableFrom = picked;
        else _availableUntil = picked;
      });
    }
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFBEC092),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
        decoration: isSelected ? const BoxDecoration(color: Color(0xFFF7F2E4), shape: BoxShape.circle) : null,
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: const Color(0xFF88844D), size: 28),
      ),
    );
  }
}

// ---------------- Image Upload Widget ----------------
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
    final List<XFile>? pickedImages = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedImages != null) {
      setState(() {
        if (_images.length + pickedImages.length > 5) {
          int availableSlots = 5 - _images.length;
          _images.addAll(pickedImages.take(availableSlots));
        } else {
          _images.addAll(pickedImages);
        }
      });

      widget.onImagesChanged(_images);
    }
  } catch (e) {
    print("Image picker error: $e");
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to pick images: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload images (up to 5)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D)),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 120,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBEC092), width: 1)),
            child: _images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF88844D)),
                        SizedBox(height: 8),
                        Text('Tap to upload images', style: TextStyle(color: Color(0xFF88844D), fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
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
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.removeAt(index);
                                  widget.onImagesChanged(_images);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
