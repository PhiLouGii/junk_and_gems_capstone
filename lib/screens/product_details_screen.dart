import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:junk_and_gems/services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/screens/shopping_cart_screen.dart';
import 'package:junk_and_gems/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'dart:math';

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
  String? _currentUserId;
  String? _token;
  List<dynamic> _similarProducts = [];
  bool _isLoadingSimilarProducts = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchSimilarProducts();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
      _token = prefs.getString('token');
    });

    print('🔐 CURRENT USER ID: $_currentUserId');
    print('🔐 CURRENT USER TOKEN: ${_token != null ? "Present" : "Missing"}');
  }

  Future<void> _fetchSimilarProducts() async {
    setState(() {
      _isLoadingSimilarProducts = true;
    });

    try {
      print('🔍 Fetching similar products...');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3003/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> allProducts = json.decode(response.body);
        
        print('📦 Total products from API: ${allProducts.length}');
        
        final filtered = allProducts
            .where((p) => p['id'].toString() != widget.product['id'])
            .take(6)
            .toList();
        
        for (var i = 0; i < filtered.length; i++) {
          final p = filtered[i];
          print('Product $i: ${p['title']}');
          print('  - Has image_data_base64: ${p['image_data_base64'] != null}');
          if (p['image_data_base64'] != null) {
            print('  - Array length: ${(p['image_data_base64'] as List).length}');
            if ((p['image_data_base64'] as List).isNotEmpty) {
              final img = p['image_data_base64'][0];
              print('  - First image type: ${img.startsWith('data:image') ? 'base64' : img.startsWith('http') ? 'URL' : 'other'}');
            }
          }
          print('  - Has image_url: ${p['image_url'] != null}');
        }
        
        setState(() {
          _similarProducts = filtered;
        });
        
        print('✅ Found ${_similarProducts.length} similar products');
      } else {
        print('❌ Failed to load similar products: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Error fetching similar products: $error');
    } finally {
      setState(() {
        _isLoadingSimilarProducts = false;
      });
    }
  }

  void _messageArtisan(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting conversation...'),
          duration: Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );

      if (_currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to message artisans.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final String artisanId = widget.product['artisan_id'] ?? '2';
      final String productId = widget.product['id'] ?? '1';

      print('=== MESSAGE ARTISAN DEBUG ===');
      print('🔐 Current User ID: $_currentUserId');
      print('🎯 Artisan ID: $artisanId');
      print('📦 Product ID: $productId');
      print('=============================');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3003/api/conversations/start'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'currentUserId': _currentUserId,
          'otherUserId': artisanId,
          'productId': productId,
          'initialMessage': 'Hi! I\'m interested in your ${widget.product['title']}. Can you tell me more about it?',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final conversation = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userName: widget.product['artisan'] ?? 'Artisan',
              otherUserId: artisanId,
              currentUserId: _currentUserId!,
              conversationId: conversation['id'].toString(),
              product: widget.product,
            ),
          ),
        );
      } else {
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start conversation: ${errorResponse['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Message artisan error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting conversation: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add items to cart'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('🛒 Adding to cart...');
      print('User ID: $_currentUserId');
      print('Product ID: ${widget.product['id']}');
      print('Product Title: ${widget.product['title']}');
      print('Quantity: $_quantity');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Adding to cart...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final result = await CartService.addToCart(
        _currentUserId!,
        widget.product['id']!,
        quantity: _quantity,
      );

      print('✅ Add to cart result: $result');

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product['title']} added to cart!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShoppingCartScreen(userId: _currentUserId!),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Add to cart error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildSimilarProductCard(dynamic product, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    
    String imageUrl = '';
    if (product['image_data_base64'] != null && 
        (product['image_data_base64'] as List).isNotEmpty) {
      imageUrl = product['image_data_base64'][0];
    } else if (product['image_url'] != null && product['image_url'].isNotEmpty) {
      imageUrl = product['image_url'];
    }

    print('🖼️ Similar product image: ${imageUrl.isNotEmpty ? imageUrl.substring(0, min(50, imageUrl.length)) : "empty"}...');

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: {
                'id': product['id'].toString(),
                'title': product['title'] ?? 'Untitled',
                'artisan': product['creator_name'] ?? 'Unknown Artisan',
                'artisan_id': product['artisan_id']?.toString() ?? '',
                'price': 'M${product['price']?.toString() ?? '0'}',
                'image': imageUrl,
                'description': product['description'] ?? '',
              },
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 92,
                width: 120,
                child: _buildSimilarProductImage(imageUrl, isDarkMode),
              ),
            ),
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product['title'] ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'M${product['price']?.toString() ?? '0'}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF88844D),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Product Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFE4E5C2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: _buildProductImage(widget.product['image']!, isDarkMode),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.eco,
                            size: 14,
                            color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Upcycled',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['title'] ?? 'Untitled Product',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                          ),
                        ),
                      ),
                      Text(
                        widget.product['price'] ?? 'M0',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF88844D),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'By ${widget.product['artisan'] ?? 'Unknown Artisan'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 (New)',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'About the Product',
                    content: widget.product['description'] ?? 'A beautifully crafted upcycled product made with care and creativity.',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Pickup & Delivery',
                    content: 'Contact the artisan to arrange pickup or delivery within your area.',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Icon(
                        Icons.recommend,
                        color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'You May Also Like',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoadingSimilarProducts
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                            ),
                          ),
                        )
                      : _similarProducts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'No similar products found',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 145,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _similarProducts.length,
                                itemBuilder: (context, index) {
                                  return _buildSimilarProductCard(
                                    _similarProducts[index],
                                    themeProvider,
                                  );
                                },
                              ),
                            ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFE4E5C2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A unique piece made with love and recycled materials.',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F2E4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.secondary),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D)),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D)),
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
            Expanded(
              child: GestureDetector(
                onTap: () => _addToCart(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _messageArtisan(context),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F2E4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary),
                ),
                child: Center(
                  child: Text(
                    'Message\nArtisan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, required bool isDarkMode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          color: Theme.of(context).colorScheme.secondary,
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildProductImage(String imageSource, bool isDarkMode) {
    print('🖼️ Loading product detail image: ${imageSource.substring(0, min(50, imageSource.length))}...');
    
    if (imageSource.startsWith('data:image')) {
      try {
        final base64String = imageSource.split(',')[1];
        final bytes = base64Decode(base64String);
        
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading base64 image: $error');
            return _buildImagePlaceholder(isDarkMode);
          },
        );
      } catch (e) {
        print('❌ Error decoding base64 image: $e');
        return _buildImagePlaceholder(isDarkMode);
      }
    }
    else if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading network image: $error');
          return _buildImagePlaceholder(isDarkMode);
        },
      );
    }
    else {
      return Image.asset(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading asset image: $error');
          return _buildImagePlaceholder(isDarkMode);
        },
      );
    }
  }

  Widget _buildSimilarProductImage(String imageSource, bool isDarkMode) {
    if (imageSource.isEmpty) {
      return _buildImagePlaceholder(isDarkMode);
    }

    if (imageSource.startsWith('data:image')) {
      try {
        final base64String = imageSource.split(',')[1];
        final bytes = base64Decode(base64String);
        
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading base64 similar product image: $error');
            return _buildImagePlaceholder(isDarkMode);
          },
        );
      } catch (e) {
        print('❌ Error decoding base64 similar product image: $e');
        return _buildImagePlaceholder(isDarkMode);
      }
    }
    else if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading network similar product image: $error');
          return _buildImagePlaceholder(isDarkMode);
        },
      );
    }
    else if (imageSource.startsWith('assets/')) {
      return Image.asset(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading asset similar product image: $error');
          return _buildImagePlaceholder(isDarkMode);
        },
      );
    }
    else {
      return _buildImagePlaceholder(isDarkMode);
    }
  }

  Widget _buildImagePlaceholder(bool isDarkMode) {
    return Container(
      color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFE4E5C2),
      child: Icon(
        Icons.recycling,
        size: 80,
        color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
      ),
    );
  }
}