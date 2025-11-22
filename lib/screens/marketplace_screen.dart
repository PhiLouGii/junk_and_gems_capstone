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
import 'package:junk_and_gems/utils/product_helper.dart';
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
  List<dynamic> _recentlyAddedProducts = [];
  bool _isLoadingNewProducts = false;
  String _searchQuery = '';
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _sortBy = 'newest';
  bool _showFilters = false;
  
  final List<String> _categoryOptions = [
    'All',
    'Home Decor',
    'Furniture',
    'Crafts',
    'Jewelry',
    'Fashion',
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

  List<dynamic> _applyFilters(List<dynamic> products) {
    var filtered = products;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) {
        final category = product['category']?.toString().toLowerCase() ?? '';
        return category.contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    filtered = filtered.where((product) {
      final priceStr = product['price']?.toString().replaceAll('M', '') ?? '0';
      final price = double.tryParse(priceStr) ?? 0;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) {
          final priceA = double.tryParse(a['price']?.toString().replaceAll('M', '') ?? '0') ?? 0;
          final priceB = double.tryParse(b['price']?.toString().replaceAll('M', '') ?? '0') ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        filtered.sort((a, b) {
          final priceA = double.tryParse(a['price']?.toString().replaceAll('M', '') ?? '0') ?? 0;
          final priceB = double.tryParse(b['price']?.toString().replaceAll('M', '') ?? '0') ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'popular':
        filtered.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        break;
    }

    return filtered;
  }

  Future<void> _loadCartCount() async {
  try {
    if (widget.userId == null || widget.userId!.isEmpty) {
      setState(() {
        _cartItemCount = 0;
      });
      return;
    }

    final cartItems = await CartService.getCartItems(widget.userId!);
    
    setState(() {
      _cartItemCount = cartItems.length;
    });
  } catch (error) {
    print('Error loading cart count: $error');
    setState(() {
      _cartItemCount = 0;
    });
  }
}

void _refreshCartCount() {
  _loadCartCount();
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

    final productId = product['id']?.toString() ?? '';
    final isStaticProduct = int.tryParse(productId) != null && int.parse(productId) < 10;

    if (isStaticProduct) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This is a sample product. Only products from the "New Products" section can be added to cart.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

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

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      
      await _loadCartCount();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['title']} added to cart'),
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
              ).then((_) => _loadCartCount()); 
            },
          ),
        ),
      );
    }
  } catch (e) {
    print('Add to cart error: $e');

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

  Future<void> _fetchNewProducts() async {
  if (_isLoadingNewProducts) return;
  
  setState(() {
    _isLoadingNewProducts = true;
  });

    try {
    final response = await http.get(
      Uri.parse('https://junk-and-gems-api.onrender.com/api/products'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
      final List<dynamic> products = json.decode(response.body);
        
        final userCreatedProducts = products.where((product) {
        final productId = int.tryParse(product['id']?.toString() ?? '0') ?? 0;
        return productId >= 17;
      }).toList();
        
        setState(() {
        if (userCreatedProducts.length <= 5) {
          _newProducts = userCreatedProducts;
          _recentlyAddedProducts = [];
        } else {
          _newProducts = userCreatedProducts.take(5).toList();
          _recentlyAddedProducts = userCreatedProducts.skip(5).toList();
        }
      });
    } else {
      setState(() {
        _newProducts = [];
        _recentlyAddedProducts = [];
      });
    }
  } catch (error) {
    print('Error fetching new products: $error');
    setState(() {
      _newProducts = [];
      _recentlyAddedProducts = [];
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
      final response = await http.get(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/products/search?query=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        setState(() {
          _searchResults = products;
        });
      } else {
        _searchLocally(query);
      }
    } catch (error) {
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
      _selectedCategory = 'All';
      _priceRange = const RangeValues(0, 1000);
      _sortBy = 'newest';
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

  Widget _buildFilterChips(double maxWidth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: const Color(0xFF88844D),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_selectedCategory != 'All')
                        _buildFilterChip(
                          _selectedCategory,
                          Icons.category,
                          () {
                            setState(() {
                              _selectedCategory = 'All';
                              if (_isSearching) {
                                _searchResults = _applyFilters(_searchResults);
                              }
                            });
                          },
                        ),
                      if (_priceRange.start > 0 || _priceRange.end < 1000)
                        _buildFilterChip(
                          'M${_priceRange.start.toInt()}-M${_priceRange.end.toInt()}',
                          Icons.attach_money,
                          () {
                            setState(() {
                              _priceRange = const RangeValues(0, 1000);
                              if (_isSearching) {
                                _searchResults = _applyFilters(_searchResults);
                              }
                            });
                          },
                        ),
                      if (_sortBy != 'newest')
                        _buildFilterChip(
                          _getSortLabel(_sortBy),
                          Icons.sort,
                          () {
                            setState(() {
                              _sortBy = 'newest';
                              if (_isSearching) {
                                _searchResults = _applyFilters(_searchResults);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.expand_less : Icons.tune,
                  color: const Color(0xFF88844D),
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ],
          ),
          
          if (_showFilters) ...[
            const SizedBox(height: 16),
            _buildFilterPanel(maxWidth),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 16, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
        onDeleted: onRemove,
        backgroundColor: const Color(0xFF88844D),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'popular':
        return 'Most Popular';
      default:
        return 'Newest First';
    }
  }

  Widget _buildFilterPanel(double maxWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBEC092).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categoryOptions.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                    if (_isSearching) {
                      _searchResults = _applyFilters(_searchResults);
                    }
                  });
                },
                selectedColor: const Color(0xFF88844D),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'M${_priceRange.start.toInt()}',
                style: TextStyle(
                  color: const Color(0xFF88844D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'M${_priceRange.end.toInt()}',
                style: TextStyle(
                  color: const Color(0xFF88844D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: const Color(0xFF88844D),
            inactiveColor: const Color(0xFFBEC092).withOpacity(0.3),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
            onChangeEnd: (RangeValues values) {
              setState(() {
                if (_isSearching) {
                  _searchResults = _applyFilters(_searchResults);
                }
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Sort By',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('Newest First', 'newest'),
              _buildSortChip('Price: Low to High', 'price_low'),
              _buildSortChip('Price: High to Low', 'price_high'),
              _buildSortChip('Most Popular', 'popular'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _priceRange = const RangeValues(0, 1000);
                  _sortBy = 'newest';
                  if (_isSearching) {
                    _searchResults = _applyFilters(_searchResults);
                  }
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF88844D),
                side: const BorderSide(color: Color(0xFF88844D)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
          if (_isSearching) {
            _searchResults = _applyFilters(_searchResults);
          }
        });
      },
      selectedColor: const Color(0xFF88844D),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 12,
      ),
    );
  }

  Widget _buildImage(String imageSource) {
    if (imageSource.startsWith('data:image')) {
      try {
        return Image.memory(
          base64Decode(imageSource.split(',')[1]),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        );
      } catch (e) {
        print('Base64 image error: $e');
        return _buildImagePlaceholder();
      }
    }
    else if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: const Color(0xFF88844D),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Network image error: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    else {
      try {
        return Image.asset(
          imageSource,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        );
      } catch (e) {
        return _buildImagePlaceholder();
      }
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFBEC092).withOpacity(0.3),
            const Color(0xFF88844D).withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo,
            size: 40,
            color: const Color(0xFF88844D).withOpacity(0.5),
          ),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: const Color(0xFF88844D).withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchNewProducts,
                color: const Color(0xFF88844D),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: maxWidth > 600 ? 24.0 : 16.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchBar(maxWidth),
                              const SizedBox(height: 16),
                              if (_isSearching) ...[
                                _buildFilterChips(maxWidth),
                                _buildSearchResults(maxWidth),
                              ] else ...[
                                _buildFeaturedProducts(maxWidth),
                                const SizedBox(height: 32),
                                _buildNewProductsSection(maxWidth),
                                if (_recentlyAddedProducts.isNotEmpty) ...[  
                                  const SizedBox(height: 32),                 
                                  _buildRecentlyAddedSection(maxWidth),     
                                ],                                            
                                const SizedBox(height: 32),
                                _buildCategories(maxWidth),
                                const SizedBox(height: 32),
                                _buildProductsGrid(maxWidth),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const CreateProductListingScreen()),
          ).then((_) {
            _fetchNewProducts();
          });
        },
        backgroundColor: const Color(0xFF88844D),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'List Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF88844D),
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store,
              color: Color(0xFF88844D),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Marketplace',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Stack(
  children: [
    Container(
      decoration: BoxDecoration(
        color: const Color(0xFFBEC092).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.shopping_cart_outlined,
          color: const Color(0xFF88844D),
          size: 26,
        ),
        onPressed: () async {
          // Wait for result and refresh if needed
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShoppingCartScreen(userId: widget.userId ?? ''),
            ),
          );
          
          // Refresh cart count when returning
          if (shouldRefresh == true || shouldRefresh == null) {
            _refreshCartCount();
          }
        },
      ),
    ),
    if (_cartItemCount > 0)
      Positioned(
        right: 6,
        top: 6,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
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
        ],
      ),
    );
  }

  Widget _buildSearchBar(double maxWidth) {
    final isLargeScreen = maxWidth > 600;
    
    return Container(
      height: isLargeScreen ? 56 : 52,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBEC092), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBEC092).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: const Color(0xFF88844D),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products, artisans...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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
                icon: Icon(Icons.clear, size: 20, color: const Color(0xFF88844D)),
                onPressed: _clearSearch,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(double maxWidth) {
    final filteredResults = _applyFilters(_searchResults);
    
    if (filteredResults.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFBEC092).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 50,
                color: const Color(0xFF88844D).withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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

    int crossAxisCount = 2;
    if (maxWidth > 900) {
      crossAxisCount = 4;
    } else if (maxWidth > 600) {
      crossAxisCount = 3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Search Results (${filteredResults.length} found)',
            style: TextStyle(
              fontSize: maxWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredResults.length,
          itemBuilder: (context, index) {
            final product = filteredResults[index];
            return _buildProductCard(product, maxWidth);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(dynamic product, double maxWidth) {
    final isFromServer = product.containsKey('creator_name');
    final title = product['title'] ?? 'Untitled';
    final artisan = isFromServer ? (product['creator_name'] ?? 'Unknown Artisan') : product['artisan']!;
    final price = isFromServer ? 'M${product['price']?.toString() ?? '0'}' : product['price']!;
    
    String image = '';
    if (isFromServer) {
      if (product['image_urls'] != null && 
          product['image_urls'] is List && 
          (product['image_urls'] as List).isNotEmpty) {
        final imageUrl = product['image_urls'][0].toString();
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
          image = imageUrl;
        }
      }
      
      if (image.isEmpty && 
          product['image_data_base64'] != null && 
          product['image_data_base64'] is List && 
          (product['image_data_base64'] as List).isNotEmpty) {
        final imageData = product['image_data_base64'][0].toString();
        if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
          image = imageData;
        } else if (imageData.startsWith('data:image')) {
          image = imageData;
        }
      }
      
      if (image.isEmpty && 
          product['image_url'] != null && 
          product['image_url'].toString().isNotEmpty) {
        final imageUrl = product['image_url'].toString();
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
          image = imageUrl;
        }
      }
      
      if (image.isEmpty) {
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
      product: ProductHelper.convertToDisplayFormat(product),
    ),
  ),
);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFBEC092).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF88844D).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: _buildImage(image),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: const Color(0xFF88844D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: maxWidth > 600 ? 15 : 14,
                      fontWeight: FontWeight.bold,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF88844D),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF88844D).withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 18,
                            color: Colors.white,
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

  Widget _buildFeaturedProducts(double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Featured Products',
              style: TextStyle(
                fontSize: maxWidth > 600 ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: maxWidth > 600 ? 260 : 250,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
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
                    width: maxWidth > 600 ? 180 : 160,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBEC092).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF88844D).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: maxWidth > 600 ? 130 : 120,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                            child: Image.asset(
                              product['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 38,
                                child: Text(
                                  product['title']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'By ${product['artisan']!}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      product['price']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF88844D),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _addToCart(product),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 16,
                                        color: Colors.white,
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

  Widget _buildNewProductsSection(double maxWidth) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF88844D),
              borderRadius: BorderRadius.circular(10),
            ),
              child: const Icon(
              Icons.fiber_new,
              color: Colors.white,
              size: 20,
            ),
          ),
            const SizedBox(width: 12),
            Expanded(
            child: Text(
              'New Products',
              style: TextStyle(
                fontSize: maxWidth > 600 ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
            Container(
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
             child: IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFF88844D),
              ),
              onPressed: _fetchNewProducts,
            ),
          ),
        ],
      ),
        const SizedBox(height: 16),
      _isLoadingNewProducts
          ? Container(
              height: 220,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFBEC092).withOpacity(0.3),
                  width: 2,
                ),
              ),
                child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: const Color(0xFF88844D),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading products...',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
            : _newProducts.isEmpty
              ? Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBEC092).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                     child: Center(
                     child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: const Color(0xFF88844D).withOpacity(0.5),
                        ),
                          const SizedBox(height: 12),
                          Text(
                            'No products yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to list a product',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: maxWidth > 600 ? 240 : 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _newProducts.length,
                      itemBuilder: (context, index) {
                        final product = _newProducts[index];

                        String title = product['title'] ?? 'Untitled';
                        String artisan = product['creator_name'] ?? 'Unknown Artisan';
                        String price = 'M${product['price']?.toString() ?? '0'}';
                        String productId = product['id']?.toString() ?? '';
                        String artisanId = product['artisan_id']?.toString() ?? '';
                        String description = product['description'] ?? '';

                        String imageSource = 'assets/images/placeholder.jpg';

                        if (product['image_urls'] != null && 
                            product['image_urls'] is List && 
                            (product['image_urls'] as List).isNotEmpty) {
                          final imageUrl = product['image_urls'][0].toString();
                          if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
                            imageSource = imageUrl;
                          }
                        }
                        
                        if (imageSource == 'assets/images/placeholder.jpg' && 
                            product['image_data_base64'] != null && 
                            product['image_data_base64'] is List && 
                            (product['image_data_base64'] as List).isNotEmpty) {
                          final imageData = product['image_data_base64'][0].toString();
                          if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
                            imageSource = imageData;
                          } else if (imageData.startsWith('data:image')) {
                            imageSource = imageData;
                          }
                        }
                        
                        if (imageSource == 'assets/images/placeholder.jpg' && 
                            product['image_url'] != null && 
                            product['image_url'].toString().isNotEmpty) {
                          final imageUrl = product['image_url'].toString();
                          if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
                            imageSource = imageUrl;
                          }
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
                            width: maxWidth > 600 ? 180 : 160,
                            margin: EdgeInsets.only(
                              right: index == _newProducts.length - 1 ? 0 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFBEC092).withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF88844D).withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: maxWidth > 600 ? 140 : 120,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                    child: _buildImage(imageSource),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'By $artisan',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              price,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF88844D),
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
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.shopping_bag_outlined,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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

   Widget _buildRecentlyAddedSection(double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.history,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Recently Added',
                style: TextStyle(
                  fontSize: maxWidth > 600 ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: maxWidth > 600 ? 240 : 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentlyAddedProducts.length,
            itemBuilder: (context, index) {
              final product = _recentlyAddedProducts[index];

              String title = product['title'] ?? 'Untitled';
              String artisan = product['creator_name'] ?? 'Unknown Artisan';
              String price = 'M${product['price']?.toString() ?? '0'}';
              String productId = product['id']?.toString() ?? '';
              String artisanId = product['artisan_id']?.toString() ?? '';
              String description = product['description'] ?? '';

              String imageSource = 'assets/images/placeholder.jpg';

              if (product['image_urls'] != null && 
                  product['image_urls'] is List && 
                  (product['image_urls'] as List).isNotEmpty) {
                final imageUrl = product['image_urls'][0].toString();
                if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
                  imageSource = imageUrl;
                }
              }
              
              if (imageSource == 'assets/images/placeholder.jpg' && 
                  product['image_data_base64'] != null && 
                  product['image_data_base64'] is List && 
                  (product['image_data_base64'] as List).isNotEmpty) {
                final imageData = product['image_data_base64'][0].toString();
                if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
                  imageSource = imageData;
                } else if (imageData.startsWith('data:image')) {
                  imageSource = imageData;
                }
              }
              
              if (imageSource == 'assets/images/placeholder.jpg' && 
                  product['image_url'] != null && 
                  product['image_url'].toString().isNotEmpty) {
                final imageUrl = product['image_url'].toString();
                if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
                  imageSource = imageUrl;
                }
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
                  width: maxWidth > 600 ? 180 : 160,
                  margin: EdgeInsets.only(
                    right: index == _recentlyAddedProducts.length - 1 ? 0 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBEC092).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF88844D).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: maxWidth > 600 ? 140 : 120,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: _buildImage(imageSource),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'By $artisan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    price,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF88844D),
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
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildCategories(double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.category,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Shop by Category',
              style: TextStyle(
                fontSize: maxWidth > 600 ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: maxWidth > 600 ? 120 : 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['name']!;
                    _isSearching = true;
                    final allProducts = [..._newProducts, ..._products.map((p) => {
                      'title': p['title'],
                      'creator_name': p['artisan'],
                      'price': p['price']?.replaceAll('M', ''),
                      'image_url': p['image'],
                      'artisan_id': p['artisan_id'],
                      'id': p['id'],
                      'description': '',
                      'category': category['name'],
                    })];
                    _searchResults = _applyFilters(allProducts);
                  });
                },
                child: Container(
                  width: maxWidth > 600 ? 100 : 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF88844D).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(category['image']!, height: 50, width: 50, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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

  Widget _buildProductsGrid(double maxWidth) {
    int crossAxisCount = 2;
    if (maxWidth > 900) {
      crossAxisCount = 4;
    } else if (maxWidth > 600) {
      crossAxisCount = 3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Items',
          style: TextStyle(
            fontSize: maxWidth > 600 ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return _buildProductCard(product, maxWidth);
          },
        ),
      ],
    );
  }
  Widget _navItem(IconData icon, bool isActive, String label, {required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFF88844D) : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF88844D) : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
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
                userName: widget.userName,
                userId: widget.userId ?? '',
              ),
            ),
          );
        }),
        _navItem(Icons.inventory_2, false, 'Browse', onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
          );
        }),
        _navItem(Icons.shopping_bag_outlined, true, 'Shop', onTap: () {}),
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
                userId: widget.userId ?? '',
                userName: widget.userName,
              ),
            ),
          );
        }),
      ],
    ),
  );
}
}