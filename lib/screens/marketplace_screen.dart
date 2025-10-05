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
  late AnimationController _animationController;
  late Animation<double> _animation;
  Map<String, String> _userData = {};
  int _cartItemCount = 1; 
  List<dynamic> _newProducts = [];
  bool _isLoadingNewProducts = false;

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

  Future<void> _fetchNewProducts() async {
    if (_isLoadingNewProducts) return;
    
    setState(() {
      _isLoadingNewProducts = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3003/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        setState(() {
          _newProducts = products;
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching new products: $error');
    } finally {
      setState(() {
        _isLoadingNewProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _featuredController.dispose();
    _animationController.dispose();
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
            // Refresh products when returning from creating a new product
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
                      MaterialPageRoute(builder: (context) => const ShoppingCartScreen()),
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
              _buildFeaturedProducts(),
              const SizedBox(height: 32),
              _buildNewProductsSection(),
              const SizedBox(height: 32),
              _buildCategories(),
              const SizedBox(height: 32),
              _buildProductsGrid(),
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
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Search products, artisans...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                ),
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
                                  Container(
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

  Widget _buildNewProductsList() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _newProducts.length,
        itemBuilder: (context, index) {
          final product = _newProducts[index];
          return GestureDetector(
            onTap: () {
              // Navigate to product details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: {
                      'title': product['title'] ?? 'Untitled',
                      'artisan': product['creator_name'] ?? 'Unknown Artisan',
                      'price': 'M${product['price']?.toString() ?? '0'}',
                      'image': product['image_url'] ?? 'assets/images/placeholder.jpg',
                      'artisan_id': product['creator_id']?.toString() ?? '',
                      'id': product['id']?.toString() ?? '',
                      'description': product['description'] ?? '',
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
                  // Product Image
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
                      child: product['image_url'] != null && product['image_url'].startsWith('http')
                          ? Image.network(
                              product['image_url'],
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
                            )
                          : product['image_url'] != null
                              ? Image.asset(
                                  product['image_url'],
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
                                )
                              : Container(
                                  color: const Color(0xFFE4E5C2),
                                  child: Icon(
                                    Icons.recycling,
                                    size: 40,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['title'] ?? 'Untitled',
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
                          'By ${product['creator_name'] ?? 'Unknown Artisan'}',
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
                              'M${product['price']?.toString() ?? '0'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            Container(
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
                              Container(
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