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
  final PageController _carouselController = PageController(viewportFraction: 0.8);
  int _currentCarouselIndex = 0;

  // More by Nthati R. products
  final List<Map<String, String>> _moreByArtisan = [
    {'title': 'Pilants', 'price': 'M250', 'image': 'assets/images/featured1.jpg'},
    {'title': 'Cassette Lamp', 'price': 'M450', 'image': 'assets/images/featured2.jpg'},
    {'title': 'Patchwork', 'price': 'M450', 'image': 'assets/images/featured3.jpg'},
    {'title': 'M250', 'price': 'M250', 'image': 'assets/images/featured4.jpg'},
    {'title': 'M450', 'price': 'M450', 'image': 'assets/images/featured5.jpg'},
  ];

  // Related products
  final List<Map<String, String>> _relatedProducts = [
    {'title': 'F99 Tay Light', 'price': 'M300', 'image': 'assets/images/related1.jpg'},
    {'title': 'Can Lamp', 'price': 'M500', 'image': 'assets/images/related2.jpg'},
    {'title': 'Umeason-L', 'price': 'M450', 'image': 'assets/images/related3.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll carousel
    _startCarouselAutoScroll();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _startCarouselAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_carouselController.hasClients) {
        final nextPage = _currentCarouselIndex + 1;
        if (nextPage >= _moreByArtisan.length) {
          _carouselController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _carouselController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        _startCarouselAutoScroll();
      }
    });
  }

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

  Widget _buildCarouselItem(Map<String, String> product, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail when tapped
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Final adjustment
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                product['image']!,
                fit: BoxFit.cover,
                height: 92, // Final reduction from 95 to 92
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 92,
                    color: const Color(0xFFE4E5C2),
                    child: const Icon(
                      Icons.recycling,
                      size: 40,
                      color: Color(0xFF88844D),
                    ),
                  );
                },
              ),
            ),
            
            // Product Info - Final adjustment
            Container(
              height: 42, // Final reduction from 45 to 42
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // Reduced vertical padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product['title']!,
                    style: const TextStyle(
                      fontSize: 12, // Slightly smaller font
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF88844D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    product['price']!,
                    style: const TextStyle(
                      fontSize: 10, // Slightly smaller font
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF88844D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProduct(Map<String, String> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E5C2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.recycling,
                    color: Color(0xFF88844D),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF88844D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['price']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF88844D),
                  ),
                ),
              ],
            ),
          ),
          
          // View Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'View',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF88844D),
              ),
            ),
          ),
        ],
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

                  const SizedBox(height: 30),
                  
                  // More by Nthati R. Section
                  const Text(
                    'More by Nthati R.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF88844D),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Carousel Slider - Final adjustment with ClipRRect to prevent overflow
                  SizedBox(
                    height: 145, // Final reduction from 150 to 145
                    child: ClipRRect(
                      // This will clip any overflow
                      child: PageView.builder(
                        controller: _carouselController,
                        itemCount: _moreByArtisan.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentCarouselIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildCarouselItem(_moreByArtisan[index], index);
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Carousel Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _moreByArtisan.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentCarouselIndex == index
                              ? const Color(0xFF88844D)
                              : const Color(0xFFBEC092).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // Related Products Section
                  const Text(
                    'Related Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF88844D),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Related Products List
                  Column(
                    children: _relatedProducts.map((product) => _buildRelatedProduct(product)).toList(),
                  ),

                  const SizedBox(height: 20),
                  
                  // Unique Piece Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E5C2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'A unique piece made with love and recycled goods.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF88844D),
                      ),
                      textAlign: TextAlign.center,
                    ),
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

            const SizedBox(width: 16),

            // Message Artisan Button
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2E4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBEC092)),
              ),
              child: const Center(
                child: Text(
                  'Message\nArtisan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF88844D),
                  ),
                  textAlign: TextAlign.center,
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