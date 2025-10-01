import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

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

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _materialsController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _materialsController.dispose();
    _dimensionsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sell Your Creation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
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
        const Text(
          'List Your Upcycled Product',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF88844D)),
        ),
        const SizedBox(height: 24),
        _buildTextField(label: 'Product Name', controller: _titleController, hintText: 'e.g., Bottle Cap Coaster Set'),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Product Description',
          controller: _descriptionController,
          hintText: 'Describe your upcycled creation, its features, and unique qualities...',
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        _buildImageUpload(),
        const SizedBox(height: 20),
        _buildDropdown(
          label: 'Product Category',
          hintText: 'Select a category',
          value: _selectedCategory,
          items: const ['Home Decor', 'Furniture', 'Fashion', 'Jewelry', 'Art', 'Crafts', 'Other'],
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Original Materials Used',
          controller: _materialsController,
          hintText: 'e.g., Detergent bottle, wood scraps, denim fabric...',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Dimensions/Size',
          controller: _dimensionsController,
          hintText: 'e.g., 12" height, 6" diameter',
        ),
        const SizedBox(height: 20),
        _buildDropdown(
          label: 'Condition',
          hintText: 'Select condition',
          value: _selectedCondition,
          items: const ['New', 'Like New', 'Excellent', 'Good', 'Fair'],
          onChanged: (value) => setState(() => _selectedCondition = value),
        ),
        const SizedBox(height: 20),
        _buildPriceField(),
        const SizedBox(height: 20),
        _buildTextField(label: 'Location', controller: _locationController, hintText: 'Enter your location'),
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

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBEC092), width: 1)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('M', style: TextStyle(fontSize: 16, color: Color(0xFF88844D), fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _price = double.tryParse(value) ?? 0.0;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: const Color(0xFF88844D).withOpacity(0.6)),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // For now, just show a success message and go back
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFFF7F2E4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF88844D)),
                  SizedBox(width: 8),
                  Text('Success!', style: TextStyle(color: Color(0xFF88844D))),
                ],
              ),
              content: const Text('Your upcycled product has been listed successfully!', style: TextStyle(color: Color(0xFF88844D))),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: Color(0xFF88844D))),
                ),
              ],
            ),
          ).then((_) {
            Navigator.pop(context);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBEC092),
          foregroundColor: const Color(0xFF88844D),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('List Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// Image Upload Widget (same as before)
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
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      List<XFile> pickedImages = result.files.map((f) => XFile(f.path!)).toList();
      
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload product images (up to 5)',
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
                        Text('Tap to upload product images', style: TextStyle(color: Color(0xFF88844D), fontSize: 14)),
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