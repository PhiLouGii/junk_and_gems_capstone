import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/shopping_cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, String> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _addToCart(BuildContext context) {
    // Create cart item from current product
    final cartItem = {
      'title': widget.product['title'] ?? 'Sta-Soft Lamp M400',
      'price': _parsePrice(widget.product['price'] ?? 'M400'),
      'image': widget.product['image'] ?? 'assets/images/featured3.jpg',
      'quantity': _quantity,
    };

    // Navigate to cart screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShoppingCartScreen()),
    );

    // In a real app, you would add the item to a cart manager or state management
    // For now, we'll just navigate to the cart screen
    _showAddedToCartMessage(context);
  }

  int _parsePrice(String price) {
    // Remove 'M' and parse to integer
    final numericPrice = price.replaceAll('M', '');
    return int.tryParse(numericPrice) ?? 400;
  }

  void _showAddedToCartMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product['title']} added to cart!'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFBEC092),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF88844D),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: Color(0xFF88844D),
            ),
            onPressed: () {
              // Add to favorites
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE4E5C2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Product Image
                  Center(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Image.asset(
                        widget.product['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE4E5C2),
                            child: const Icon(
                              Icons.recycling,
                              size: 80,
                              color: Color(0xFF88844D),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Discount Badge (if any)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEC092),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '20% OFF',
                        style: TextStyle(
                          color: Color(0xFF88844D),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['title'] ?? 'Sta-Soft Lamp',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF88844D),
                          ),
                        ),
                      ),
                      Text(
                        widget.product['price'] ?? 'M400',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF88844D),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Artisan Name and Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Color(0xFF88844D),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'By ${widget.product['artisan'] ?? 'Nthati Radiapole'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.6 (110 Reviews)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // About the Product Section
                  _buildSection(
                    title: 'About the Product',
                    content: 'Eco-friendly elegance: a uniquely crafted upcycled lamp made from a detergent container, casting beautiful leaf-pattern shadows.',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Original Material Section
                  _buildSection(
                    title: 'Original Material',
                    content: 'Cleaning detergent bottle',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Product Specifications
                  _buildSection(
                    title: 'Specifications',
                    content: '• Height: 12 inches\n• Base diameter: 6 inches\n• Bulb: LED E27 (included)\n• Power cord: 6 feet',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Shipping Information
                  _buildSection(
                    title: 'Pickup & Drop-off',
                    content: 'Contact the Artisan to arrange pickup or delivery within your area.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Action Bar
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2E4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBEC092)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Color(0xFF88844D)),
                    onPressed: () {
                      setState(() {
                        if (_quantity > 1) {
                          _quantity--;
                        }
                      });
                    },
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF88844D),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF88844D)),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Add to Cart Button
            Expanded(
              child: GestureDetector(
                onTap: () => _addToCart(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEC092),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF88844D),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(
          color: Color(0xFFBEC092),
          thickness: 1,
        ),
      ],
    );
  }
}