import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';

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
        Text(
          'List Your Upcycled Product',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: 'Product Name', 
          controller: _titleController, 
          hintText: 'e.g., Bottle Cap Coaster Set'
        ),
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
        _buildTextField(
          label: 'Location', 
          controller: _locationController, 
          hintText: 'Enter your location'
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

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price', 
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
            child: Row(
              children: [
                Text(
                  'M', 
                  style: TextStyle(
                    fontSize: 16, 
                    color: Theme.of(context).textTheme.bodyLarge?.color, 
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    onChanged: (value) {
                      setState(() {
                        _price = double.tryParse(value) ?? 0.0;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
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
      onPressed: () async {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle, 
                    color: Theme.of(context).textTheme.bodyLarge?.color
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Success!', 
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)
                  ),
                ],
              ),
              content: Text(
                'Your upcycled product has been listed successfully!', 
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK', 
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)
                  ),
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
        Text(
          'Upload product images (up to 5)',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Theme.of(context).textTheme.bodyLarge?.color
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
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
                          'Tap to upload product images', 
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color, 
                            fontSize: 14
                          )
                        ),
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
                                decoration: const BoxDecoration(
                                  color: Colors.black54, 
                                  shape: BoxShape.circle
                                ),
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