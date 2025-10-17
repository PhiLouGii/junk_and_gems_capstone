import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:junk_and_gems/screens/browse_materials_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'package:junk_and_gems/screens/profile_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';
import 'package:junk_and_gems/screens/product_details_screen.dart'; 
import 'package:junk_and_gems/screens/shopping_cart_screen.dart';
import 'package:junk_and_gems/screens/create_product_listing_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/services/cart_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketplaceScreen extends StatefulWidget {
  final String userName;
  final String? userId;

  const MarketplaceScreen({super.key, required this.userName, this.userId});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  final ScrollController _featuredController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  Map<String, String> _userData = {};
  int _cartItemCount = 0;
  List<dynamic> _newProducts = [];
  bool _isLoadingNewProducts = false;
  String _searchQuery = '';
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  // ADD THIS: Static new products list with local assets
  final List<Map<String, String>> _staticNewProducts = [
    {
      'id': '17',
      'title': 'Recycled Plastic Planter',
      'artisan': 'Green Thumb Studios',
      'artisan_id': '14',
      'price': 'M320',
      'image': 'assets/images/featured3.jpg', // REPLACE WITH YOUR ACTUAL IMAGE
      'description': 'Eco-friendly planter made from recycled plastic bottles',
    },
    {
      'id': '18',
      'title': 'Vintage Suitcase Table',
      'artisan': 'Retro Revival',
      'artisan_id': '15',
      'price': 'M680',
      'image': 'assets/images/featured4.jpg', // REPLACE WITH YOUR ACTUAL IMAGE
      'description': 'Unique coffee table crafted from vintage suitcase',
    },
    {
      'id': '19',
      'title': 'Fabric Scrap Cushions',
      'artisan': 'Cozy Corners',
      'artisan_id': '16',
      'price': 'M240',
      'image': 'assets/images/featured6.jpg', // REPLACE WITH YOUR ACTUAL IMAGE
      'description': 'Colorful cushions made from fabric scraps',
    },
    {
      'id': '20',
      'title': 'Wire Sculpture Bird',
      'artisan': 'Metal Magic',
      'artisan_id': '17',
      'price': 'M480',
      'image': 'assets/images/featured5.jpg', // REPLACE WITH YOUR ACTUAL IMAGE
      'description': 'Artistic bird sculpture from recycled wire',
    },
    {
      'id': '21',
      'title': 'Book Page Wall Art',
      'artisan': 'Paper Dreams',
      'artisan_id': '18',
      'price': 'M350',
      'image': 'assets/images/featured9.jpg', // REPLACE WITH YOUR ACTUAL IMAGE
      'description': 'Beautiful wall art made from old book pages',
    },
    {
      'id': '22',
      'title': 'Tin Can Organizer',
      'artisan': 'Tidy Treasures',
      'artisan_id': '19',
      'price': 'M180',
      'image': 'assets/images/featured7.jpg', // REPLACE WITH YOUR ACTUAL IMAGE
      'description': 'Practical desk organizer from upcycled tin cans',
    },
  ];

  final List<Map<String, String>> _featuredProducts = [
    {
      'title': 'Fabric and Denim Patchwork Jacket',
      'artisan': 'Lexie Grey',
      'price': 'M450',
      'image': 'assets/images/featured1.jpg',
      'artisan_id': '2', 
      'id': '1', 
    },
    {
      'title': 'Beer Bottle Lamp',
      'artisan': 'Philippa Giibwa', 
      'price': 'M380',
      'image': 'assets/images/featured2.jpg',
      'artisan_id': '3', 
      'id': '2',
    },
    {
      'title': 'Sta-Soft Lamp',
      'artisan': 'Nthati Radiapole',
      'price': 'M300',
      'image': 'assets/images/featured3.jpg',
      'artisan_id': '10', 
      'id': '3',
    },
    {
      'title': 'Belt Patchwork Bag',
      'artisan': 'Mark Sloan',
      'price': 'M200',
      'image': 'assets/images/featured4.jpg',
      'artisan_id': '5', 
      'id': '4',
    },
    {
      'title': 'Denim Patchwork Bag',
      'artisan': 'Maya Bishop',
      'price': 'M330',
      'image': 'assets/images/upcycled1.jpg',
      'artisan_id': '7', 
      'id': '5',
    },
    {
      'title': 'Shoelace Table Coasters',
      'artisan': 'Arizona Robbins',
      'price': 'M250',
      'image': 'assets/images/featured6.jpg',
      'artisan_id': '11', 
      'id': '6',
    },
  ];

  final List<Map<String, String>> _categories = [
    {'name': 'Home Decor', 'image': 'assets/images/home_decor.jpg'},
    {'name': 'Furniture', 'image': 'assets/images/home_furniture.jpg'},
    {'name': 'Crafts', 'image': 'assets/images/crafts.jpg'},
    {'name': 'Jewelry', 'image': 'assets/images/jewelry.jpg'},
    {'name': 'Fashion', 'image': 'assets/images/fashion.jpg'},
  ];

  final List<Map<String, String>> _products = [
    {
      'title': 'Sta-Soft Lamp',
      'artisan': 'Nthati Radiapole',
      'price': 'M300',
      'image': 'assets/images/featured3.jpg',
      'artisan_id': '10', 
      'id': '3',
    },
    {
      'title': 'Belt Patchwork Bag',
      'artisan': 'Mark Sloan',
      'price': 'M200',
      'image': 'assets/images/featured4.jpg',
      'artisan_id': '5', 
      'id': '4',
    },
    {
      'title': 'Denim Patchwork Bag',
      'artisan': 'Maya Bishop',
      'price': 'M330',
      'image': 'assets/images/upcycled1.jpg',
      'artisan_id': '7',
      'id': '5',
    },
    {
      'title': 'Shoelace Table Coasters',
      'artisan': 'Arizona Robbins',
      'price': 'M250',
      'image': 'assets/images/featured6.jpg',
      'artisan_id': '11', 
      'id': '6',
    },
    {
      'title': 'Broken China Mosaic',
      'artisan': 'Mahloli Makhetha',
      'price': 'M250',
      'image': 'assets/images/featured5.jpg',
      'artisan_id': '12', 
      'id': '13',
    },
    {
      'title': 'Bottle Cap Soap Dish',
      'artisan': 'Deborah Pholo',
      'price': 'M200',
      'image': 'assets/images/featured7.jpg',
      'artisan_id': '12', 
      'id': '14',
    },
    {
      'title': 'Shoprite Shower curtain',
      'artisan': 'Limakatso Liphoto',
      'price': 'M200',
      'image': 'assets/images/featured8.jpg',
      'artisan_id': '12', 
      'id': '15',
    },
    {
      'title': 'Cassette Wall Art',
      'artisan': 'Angharad West',
      'price': 'M650',
      'image': 'assets/images/featured9.jpg',
      'artisan_id': '12', 
      'id': '16',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
    _loadUserData();
    _fetchNewProducts();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      setState(() {
        _cartItemCount = 0;
      });
    } catch (error) {
      print('Error loading cart count: $error');
      setState(() {
        _cartItemCount = 0;
      });
    }
  }

  void _addToCart(Map<String, dynamic> product) async {
    try {
      if (widget.userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to add items to cart'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('🛒 Adding to cart from Marketplace...');
      print('User ID: ${widget.userId}');
      print('Product ID: ${product['id']}');
      print('Product Title: ${product['title']}');

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
        widget.userId!,
        product['id']?.toString() ?? '',
        quantity: 1,
      );

      print('✅ Add to cart result: $result');

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['title']} added to cart!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShoppingCartScreen(userId: widget.userId!),
                  ),
                );
              },
            ),
          ),
        );
        
        setState(() {
          _cartItemCount += 1;
        });
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

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_featuredController.hasClients) {
        const scrollDuration = Duration(seconds: 30);
        final maxScroll = _featuredController.position.maxScrollExtent;
        
        _featuredController.animateTo(
          maxScroll,
          duration: scrollDuration,
          curve: Curves.linear,
        ).then((_) {
          _featuredController.animateTo(
            0,
            duration: scrollDuration,
            curve: Curves.linear,
          ).then((_) {
            _startAutoScroll();
          });
        });
      }
    });
  }

  // UPDATED: Fetch new products with fallback to static
  Future<void> _fetchNewProducts() async {
    if (_isLoadingNewProducts) return;
    
    setState(() {
      _isLoadingNewProducts = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3003/api/products'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        
        // Combine API products with static products
        if (products.isNotEmpty) {
          setState(() {
            _newProducts = [...products, ..._staticNewProducts];
          });
          print('✅ Loaded ${products.length} API products + ${_staticNewProducts.length} static products');
        } else {
          setState(() {
            _newProducts = _staticNewProducts;
          });
          print('ℹ️ No API products, showing ${_staticNewProducts.length} static products');
        }
      } else {
        print('⚠️ Failed to load products: ${response.statusCode}, using static products');
        setState(() {
          _newProducts = _staticNewProducts;
        });
      }
    } catch (error) {
      print('❌ Error fetching new products: $error');
      print('ℹ️ Using static products as fallback');
      setState(() {
        _newProducts = _staticNewProducts;
      });
    } finally {
      setState(() {
        _isLoadingNewProducts = false;
      });
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      print('🔍 Searching products for: "$query"');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3003/api/products/search?query=$query'),
      );

      print('📡 Search response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        print('✅ Found ${products.length} products matching "$query"');
        
        setState(() {
          _searchResults = products;
        });
      } else {
        print('❌ Search server error: ${response.statusCode}');
        _searchLocally(query);
      }
    } catch (error) {
      print('❌ Error searching products: $error');
      _searchLocally(query);
    }
  }

  void _searchLocally(String query) {
    final lowercaseQuery = query.toLowerCase();
    final allProducts = [..._newProducts, ..._products.map((p) => {
      'title': p['title'],
      'creator_name': p['artisan'],
      'price': p['price']?.replaceAll('M', ''),
      'image_url': p['image'],
      'artisan_id': p['artisan_id'],
      'id': p['id'],
      'description': '',
    })];
    
    final results = allProducts.where((product) {
      final title = product['title']?.toString().toLowerCase() ?? '';
      final description = product['description']?.toString().toLowerCase() ?? '';
      final artisan = product['creator_name']?.toString().toLowerCase() ?? 
                     product['artisan']?.toString().toLowerCase() ?? '';
      
      return title.contains(lowercaseQuery) ||
             description.contains(lowercaseQuery) ||
             artisan.contains(lowercaseQuery);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _featuredController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userData = {
        'name': prefs.getString('userName') ?? 'User',
        'userId': prefs.getString('userId') ?? '',
      };
    });
  }

  Widget _buildImage(String imageSource) {
    if (imageSource.startsWith('data:image')) {
      return Image.memory(
        base64Decode(imageSource.split(',')[1]),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading base64 image: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    else if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading network image: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    else {
      return Image.asset(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading asset image: $error');
          return _buildImagePlaceholder();
        },
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE4E5C2),
      child: Icon(
        Icons.recycling,
        size: 40,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNavBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProductListingScreen()),
          ).then((_) {
            _fetchNewProducts();
          });
        },
        backgroundColor: const Color(0xFFBEC092),
        foregroundColor: const Color(0xFF88844D),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Marketplace',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: Theme.of(context).iconTheme.color,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShoppingCartScreen(userId: widget.userId ?? '')),
                    );
                  },
                ),
                if (_cartItemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _animation.value,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _cartItemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNewProducts,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 24),
              if (_isSearching) ...[
                _buildSearchResults(),
              ] else ...[
                _buildFeaturedProducts(),
                const SizedBox(height: 32),
                _buildNewProductsSection(),
                const SizedBox(height: 32),
                _buildCategories(),
                const SizedBox(height: 32),
                _buildProductsGrid(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBEC092),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Search products, artisans...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (value == _searchController.text) {
                      _searchProducts(value);
                    }
                  });
                },
                onSubmitted: _searchProducts,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                onPressed: _clearSearch,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Search Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_searchResults.length} found)',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _clearSearch,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: const Color(0xFF88844D),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_searchResults.isEmpty)
          _buildEmptySearchResults()
        else
          _buildSearchResultsGrid(),
      ],
    );
  }

  Widget _buildEmptySearchResults() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBEC092),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 50,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    final isFromServer = product.containsKey('creator_name');
    final title = product['title'] ?? 'Untitled';
    final artisan = isFromServer ? (product['creator_name'] ?? 'Unknown Artisan') : product['artisan']!;
    final price = isFromServer ? 'M${product['price']?.toString() ?? '0'}' : product['price']!;
    
    String image = '';
    if (isFromServer) {
      if (product['image_data_base64'] != null && product['image_data_base64'] is List && (product['image_data_base64'] as List).isNotEmpty) {
        image = product['image_data_base64'][0];
      } 
      else if (product['image_url'] != null && product['image_url'].toString().isNotEmpty) {
        image = product['image_url'];
      } 
      else {
        image = 'assets/images/placeholder.jpg';
      }
    } else {
      image = product['image'] ?? 'assets/images/placeholder.jpg';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: {
                'title': title,
                'artisan': artisan,
                'price': price,
                'image': image,
                'artisan_id': product['artisan_id']?.toString() ?? '',
                'id': product['id']?.toString() ?? '',
                'description': product['description'] ?? '',
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                color: Color(0xFFE4E5C2),
            ),
            child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildImage(image),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By $artisan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _addToCart({
                            'id': product['id']?.toString() ?? '',
                            'title': title,
                            'price': price,
                            'image': image,
                            'artisan': artisan,
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBEC092),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is UserScrollNotification &&
                  scrollNotification.direction != ScrollDirection.idle) {
              }
              return false;
            },
            child: ListView.builder(
              controller: _featuredController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _featuredProducts.length * 3,
              itemBuilder: (context, index) {
                final productIndex = index % _featuredProducts.length;
                final product = _featuredProducts[productIndex];
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            color: const Color(0xFFE4E5C2),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.asset(
                              product['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFE4E5C2),
                                  child: Icon(
                                    Icons.recycling,
                                    size: 40,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'By ${product['artisan']!}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product['price']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _addToCart(product);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFBEC092),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 16,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'New Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              onPressed: _fetchNewProducts,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingNewProducts
            ? _buildLoadingIndicator()
            : _newProducts.isEmpty
                ? _buildEmptyNewProducts()
                : _buildNewProductsList(),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 220,
      child: Center(
        child: CircularProgressIndicator(
          color: const Color(0xFFBEC092),
        ),
      ),
    );
  }

  Widget _buildEmptyNewProducts() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBEC092),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No products yet',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to list a product!',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED: Build new products list with static/API product handling
  Widget _buildNewProductsList() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _newProducts.length,
        itemBuilder: (context, index) {
          final product = _newProducts[index];
          
          // Check if this is a static product (has 'image' key) or API product
          final isStaticProduct = product is Map<String, String> && product.containsKey('image');
          
          String imageSource = '';
          String title = '';
          String artisan = '';
          String price = '';
          String productId = '';
          String artisanId = '';
          String description = '';
          
          if (isStaticProduct) {
            // Static product from assets
            imageSource = product['image']!;
            title = product['title']!;
            artisan = product['artisan']!;
            price = product['price']!;
            productId = product['id']!;
            artisanId = product['artisan_id']!;
            description = product['description']!;
          } else {
            // API product
            title = product['title'] ?? 'Untitled';
            artisan = product['creator_name'] ?? 'Unknown Artisan';
            price = 'M${product['price']?.toString() ?? '0'}';
            productId = product['id']?.toString() ?? '';
            artisanId = product['artisan_id']?.toString() ?? '';
            description = product['description'] ?? '';
            
            // Get image from API product
            if (product['image_data_base64'] != null && 
                product['image_data_base64'] is List && 
                (product['image_data_base64'] as List).isNotEmpty) {
              imageSource = product['image_data_base64'][0];
            } else if (product['image_url'] != null && 
                       product['image_url'].toString().isNotEmpty) {
              imageSource = product['image_url'];
            } else {
              imageSource = 'assets/images/placeholder.jpg';
            }
          }
          
          print('🖼️ New Product: $title, Type: ${isStaticProduct ? "static asset" : "API"}, Image: ${imageSource.substring(0, imageSource.length > 50 ? 50 : imageSource.length)}...');
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: {
                      'title': title,
                      'artisan': artisan,
                      'price': price,
                      'image': imageSource,
                      'artisan_id': artisanId,
                      'id': productId,
                      'description': description,
                    },
                  ),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: EdgeInsets.only(
                right: index == _newProducts.length - 1 ? 0 : 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      color: const Color(0xFFE4E5C2),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: _buildImage(imageSource),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'By $artisan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _addToCart({
                                  'id': productId,
                                  'title': title,
                                  'price': price,
                                  'image': imageSource,
                                  'artisan': artisan,
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBEC092),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Container(
                width: 120,
                margin: EdgeInsets.only(
                  right: index == _categories.length - 1 ? 0 : 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.asset(
                        category['image']!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFBEC092),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            category['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        color: Color(0xFFE4E5C2),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          product['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE4E5C2),
                              child: Icon(
                                Icons.recycling,
                                size: 40,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'By ${product['artisan']!}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product['price']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _addToCart(product);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBEC092),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 16,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, false, 'Home', onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  userName: _userData['name']!,
                  userId: _userData['userId'] ?? '',
                ),
              ),
            );
          }),
          _navItem(Icons.inventory_2_outlined, false, 'Browse', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BrowseMaterialsScreen(),
              ),
            );
          }),
          _navItem(Icons.shopping_bag_outlined, true, 'Shop', onTap: () {
            // Already on marketplace
          }),
          _navItem(Icons.notifications_outlined, false, 'Alerts', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsMessagesScreen()),
            );
          }),
          _navItem(Icons.person_outline, false, 'Profile', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userName: _userData['name']!, 
                  userId: _userData['userId'] ?? ''
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isSelected, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF88844D) : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF88844D) : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}