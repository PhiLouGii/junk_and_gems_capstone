import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:junk_and_gems/screens/checkout_screen.dart';
import 'package:junk_and_gems/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/services/cart_service.dart';
import 'package:junk_and_gems/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/utils/app_localizations.dart';

class ShoppingCartScreen extends StatefulWidget {
  final String userId;
  
  const ShoppingCartScreen({super.key, required this.userId});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> with WidgetsBindingObserver {
  List<dynamic> _cartItems = [];
  int _availableGems = 0;
  int _appliedGems = 0;
  final TextEditingController _gemsController = TextEditingController();
  bool _isLoading = true; // Start as loading
  bool _hasAuthError = false;
  String _token = '';
  bool _isInitialLoad = true; // Track if this is the first load

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  print(' ShoppingCart initState - Loading data...');
  // Load data immediately
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkAuthAndLoadData();
  });
}

  @override
  void didUpdateWidget(ShoppingCartScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
  // Reload cart data if userId changed
  if (oldWidget.userId != widget.userId) {
    print('UserId changed, reloading cart data...');
    // Clear existing data first
    setState(() {
      _cartItems = [];
      _availableGems = 0;
      _appliedGems = 0;
    });
    _checkAuthAndLoadData();
  }
}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload cart when app comes to foreground
      print('App resumed, refreshing cart...');
      _checkAuthAndLoadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gemsController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadData() async {
  // Prevent concurrent loads
  if (_isLoading) {
    print(' Already loading, skipping duplicate load request');
    return;
  }

  if (!mounted) return;

  setState(() {
    _isLoading = true;
    _hasAuthError = false;
  });

    try {
    print('=' * 50);
    print('AUTHENTICATION CHECK STARTED');
    print('User ID: ${widget.userId}');
    print('=' * 50);
    
    await ApiService.debugAuthData();
      
      final token = await ApiService.getToken();
    _token = token ?? '';
    print('Token exists: ${token != null}');
      
      if (_token.isNotEmpty) {
      print('Token preview: ${_token.substring(0, min(20, _token.length))}...');
    }
      
      final userId = await ApiService.getUserId();
      print('User ID from storage: $userId');
      print('User ID from widget: ${widget.userId}');
      
      if (userId != null && userId != widget.userId) {
      print('WARNING: User ID mismatch!');
    }
      
      final isValid = await ApiService.verifyToken();
    print('Token validation: $isValid');

      
      if (_token.isEmpty || !isValid) {
      print('Token is missing, invalid, or expired');
      if (mounted) {
        setState(() {
          _hasAuthError = true;
          _isLoading = false;
        });
      }
      return;
    }

      print('Authentication verified - Loading cart data...');
      print('=' * 50);
      
      // Load cart data after authentication is verified
      await _loadCartData();
      
    } catch (e) {
    print('Auth check error: $e');
    print('Stack trace: ${StackTrace.current}');
    if (mounted) {
      setState(() {
        _hasAuthError = true;
        _isLoading = false;
      });
    }
  }
}

  Future<void> _loadCartData() async {
    print('=== LOADING CART DATA ===');
    print('User ID: ${widget.userId}');
    print('Mounted: $mounted');
    print('Current _isLoading: $_isLoading');
    
    try {
      int userGems = 0;
      List<dynamic> cartItems = [];

      // Load user gems
      try {
        print('📦 Fetching user gems...');
        userGems = await CartService.getUserGems(widget.userId);
        print('✅ User gems loaded: $userGems');
      } catch (e) {
        print('❌ Could not load user gems: $e');
        userGems = 0;
        
        if (_isAuthError(e)) {
          _handleAuthError();
          return;
        }
      }

      // Load cart items - THIS IS THE CRITICAL PART
      try {
        print('📦 Fetching cart items from API...');
        cartItems = await CartService.getCartItems(widget.userId);
        print('✅ API RETURNED: ${cartItems.length} items');
        
        // Debug: Print details of loaded items
        if (cartItems.isNotEmpty) {
          print('📋 Cart contents from API:');
          for (var item in cartItems) {
            print('  - ${item['title']} (ID: ${item['cart_item_id']}, Qty: ${item['quantity']}, Price: ${item['price']})');
          }
        } else {
          print('⚠️ API returned empty list (no items in cart)');
        }
      } catch (e) {
        print('❌ ERROR loading cart items: $e');
        print('Stack trace: ${StackTrace.current}');
        
        if (_isAuthError(e)) {
          _handleAuthError();
          return;
        }
        
        // Even if loading fails, set empty list
        cartItems = [];
      }

      // CRITICAL: Update state with loaded data
      if (mounted) {
        print('🔄 Calling setState with ${cartItems.length} items...');
        setState(() {
          _cartItems = List.from(cartItems); // Create new list to ensure rebuild
          _availableGems = userGems;
          _isLoading = false; // ONLY set to false after data is set
          _hasAuthError = false;
        });
        
        print('✅ setState completed');
        print('📊 _cartItems.length is now: ${_cartItems.length}');
        print('💎 _availableGems is now: $_availableGems');
        print('⏳ _isLoading is now: $_isLoading');
      } else {
        print('⚠️ Widget not mounted, skipping setState');
      }
      
    } catch (e) {
      print('❌ CRITICAL ERROR in _loadCartData: $e');
      print('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        setState(() {
          _cartItems = [];
          _availableGems = 0;
          _isLoading = false;
        });
      }
    }
    
    print('=== CART DATA LOADING COMPLETE ===');
    print('Final state: _cartItems=${_cartItems.length}, _isLoading=$_isLoading');
  }

  bool _isAuthError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('Session expired') || 
           errorStr.contains('Please login') ||
           errorStr.contains('Authentication failed') ||
           errorStr.contains('not authenticated');
  }

  void _handleAuthError() {
    setState(() {
      _hasAuthError = true;
      _isLoading = false;
    });
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double get _total {
    final gemDiscount = _appliedGems.toDouble();
    return _subtotal - gemDiscount;
  }

  int get _maxAllowedGems {
    return (_availableGems * 0.1).floor();
  }

  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      await CartService.updateCartItem(widget.userId, itemId, newQuantity);
      
      setState(() {
        final itemIndex = _cartItems.indexWhere((item) => item['cart_item_id'].toString() == itemId);
        if (itemIndex != -1) {
          _cartItems[itemIndex]['quantity'] = newQuantity;
        }
      });
    } catch (e) {
      print('❌ Error updating quantity: $e');
      _showErrorSnackBar('Failed to update quantity');
      
      if (_isAuthError(e)) {
        _handleAuthError();
      }
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await CartService.removeFromCart(widget.userId, itemId);
      
      setState(() {
        _cartItems.removeWhere((item) => item['cart_item_id'].toString() == itemId);
      });
      
      _showSuccessSnackBar('Item removed from cart');
    } catch (e) {
      print('❌ Error removing item: $e');
      _showErrorSnackBar('Failed to remove item');
      
      if (_isAuthError(e)) {
        _handleAuthError();
      }
    }
  }

  void _applyGems() {
    final gems = int.tryParse(_gemsController.text) ?? 0;
    final maxAllowed = _maxAllowedGems;
    
    setState(() {
      if (gems > maxAllowed) {
        _appliedGems = maxAllowed;
        _gemsController.text = maxAllowed.toString();
        _showWarningSnackBar('Maximum allowed gems is $maxAllowed (10% of total)');
      } else if (gems > _availableGems) {
        _appliedGems = _availableGems;
        _gemsController.text = _availableGems.toString();
        _showWarningSnackBar('Cannot apply more gems than you have');
      } else {
        _appliedGems = gems;
        if (gems > 0) {
          _showSuccessSnackBar('$gems gems applied successfully! 💎');
        }
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF88844D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _retryLoadData() async {
    setState(() {
      _isLoading = true;
      _hasAuthError = false;
    });
    await _checkAuthAndLoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.pop(context, true); // Signal refresh needed
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shopping Cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (!_isLoading && !_hasAuthError && _cartItems.isNotEmpty)
                      Text(
                        '${_cartItems.length} ${_cartItems.length == 1 ? 'item' : 'items'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF88844D),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // CRITICAL: Show loading state while fetching data
    if (_isLoading) {
      return _buildLoadingState();
    }

    // Show auth error if not authenticated
    if (_hasAuthError) {
      return _buildAuthErrorScreen();
    }

    // ONLY show empty cart if we're NOT loading AND cart is actually empty
    // This prevents showing empty state while data is being fetched
    if (!_isLoading && _cartItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _checkAuthAndLoadData,
        color: const Color(0xFF88844D),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildEmptyCart(),
          ),
        ),
      );
    }

    // Show cart items
    return RefreshIndicator(
      onRefresh: _checkAuthAndLoadData,
      color: const Color(0xFF88844D),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          
          if (isWideScreen) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: _buildCartItems(),
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildGemsSection(),
                        const SizedBox(height: 20),
                        _buildOrderSummary(),
                        const SizedBox(height: 20),
                        _buildCheckoutButton(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildCartItems(),
                        const SizedBox(height: 20),
                        _buildGemsSection(),
                        const SizedBox(height: 20),
                        _buildOrderSummary(),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF88844D),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your cart...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Authentication Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please login to access your shopping cart and gems.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _navigateToLogin,
                  icon: const Icon(Icons.login, size: 20),
                  label: const Text('Login Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF88844D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _retryLoadData,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBEC092), width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Color(0xFF88844D),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add some amazing items to get started!',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, true); // Signal refresh
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Browse Marketplace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return Column(
      children: _cartItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Column(
          children: [
            _buildCartItemCard(item),
            if (index < _cartItems.length - 1) const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCartItemCard(Map<String, dynamic> item) {
    // Handle different image data formats from API
    String? imageUrl;
    
    if (item['image_data_base64'] != null) {
      if (item['image_data_base64'] is List && (item['image_data_base64'] as List).isNotEmpty) {
        final firstImage = item['image_data_base64'][0];
        // Check if it's a Cloudinary URL or base64 data
        if (firstImage.toString().startsWith('http://') || firstImage.toString().startsWith('https://')) {
          imageUrl = firstImage.toString();
        } else if (firstImage.toString().startsWith('data:image')) {
          imageUrl = firstImage.toString();
        } else {
          // Assume it's base64 without prefix
          imageUrl = 'data:image/jpeg;base64,$firstImage';
        }
      }
    }
    
    print('🖼️ Cart item "${item['title']}" image URL: $imageUrl');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 100,
              height: 100,
              color: const Color(0xFFBEC092).withOpacity(0.2),
              child: imageUrl != null
                  ? _buildImageWidget(imageUrl)
                  : _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['title'] ?? 'Unknown Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                        size: 22,
                      ),
                      onPressed: () => _showDeleteDialog(item),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'M${item['price'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBEC092), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          final newQuantity = (item['quantity'] ?? 1) - 1;
                          if (newQuantity >= 1) {
                            _updateQuantity(item['cart_item_id'].toString(), newQuantity);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBEC092).withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          (item['quantity'] ?? 1).toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          final newQuantity = (item['quantity'] ?? 1) + 1;
                          _updateQuantity(item['cart_item_id'].toString(), newQuantity);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBEC092).withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
    );
  }

  Widget _buildImageWidget(String imageSource) {
    // Handle Cloudinary URLs (http/https)
    if (imageSource.startsWith('http://') || imageSource.startsWith('https://')) {
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
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image load error: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    // Handle base64 data URLs
    else if (imageSource.startsWith('data:image')) {
      try {
        final base64String = imageSource.split(',')[1];
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Base64 decode error: $error');
            return _buildImagePlaceholder();
          },
        );
      } catch (e) {
        print('❌ Base64 processing error: $e');
        return _buildImagePlaceholder();
      }
    }
    // Fallback
    else {
      print('⚠️ Unknown image format: ${imageSource.substring(0, min(50, imageSource.length))}...');
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFBEC092).withOpacity(0.2),
      child: const Icon(
        Icons.shopping_bag_outlined,
        size: 40,
        color: Color(0xFF88844D),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text('Remove Item'),
          ],
        ),
        content: Text('Remove "${item['title']}" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeItem(item['cart_item_id'].toString());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildGemsSection() {
    final maxAllowed = _maxAllowedGems;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFBEC092).withOpacity(0.2),
            const Color(0xFF88844D).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBEC092).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.diamond, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Apply Gems',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 6),
                    Text(
                      'Available: $_availableGems Gems',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Max allowed: $maxAllowed Gems (10% of total)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '100 Gems = M100',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF88844D),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBEC092), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _gemsController,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter gems',
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final gems = int.tryParse(value) ?? 0;
                        final maxAllowed = _maxAllowedGems;
                        
                        if (gems > maxAllowed) {
                          setState(() {
                            _appliedGems = maxAllowed;
                            _gemsController.text = maxAllowed.toString();
                            _gemsController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _gemsController.text.length),
                            );
                          });
                        } else if (gems > _availableGems) {
                          setState(() {
                            _appliedGems = _availableGems;
                            _gemsController.text = _availableGems.toString();
                            _gemsController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _gemsController.text.length),
                            );
                          });
                        } else {
                          setState(() {
                            _appliedGems = gems;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _applyGems,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF88844D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFBEC092).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF88844D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSummaryRow('Subtotal', 'M${_subtotal.toStringAsFixed(2)}'),
          
          if (_appliedGems > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF88844D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.diamond, size: 16, color: Color(0xFF88844D)),
                  const SizedBox(width: 8),
                  Text(
                    'Gems Discount',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '-M${_appliedGems.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF88844D),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Divider(
            color: const Color(0xFFBEC092).withOpacity(0.5),
            thickness: 1,
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF88844D), Color(0xFFBEC092)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'M${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                cartItems: _cartItems.cast<Map<String, dynamic>>(),
                subtotal: _subtotal,
                gemsDiscount: _appliedGems.toDouble(),
                total: _total,
                userId: widget.userId,
                token: _token,
              ),
            ),
          );
          // Reload cart after returning from checkout
          await _checkAuthAndLoadData();
        },
        icon: const Icon(Icons.shopping_bag, size: 22),
        label: const Text(
          'Proceed to Checkout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF88844D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, true); // Signal refresh
                    },
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text('Continue Shopping'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF88844D),
                      side: const BorderSide(color: Color(0xFFBEC092), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            cartItems: _cartItems.cast<Map<String, dynamic>>(),
                            subtotal: _subtotal,
                            gemsDiscount: _appliedGems.toDouble(),
                            total: _total,
                            userId: widget.userId,
                            token: _token,
                          ),
                        ),
                      );
                      // Reload cart after returning from checkout
                      await _checkAuthAndLoadData();
                    },
                    icon: const Icon(Icons.shopping_bag, size: 20),
                    label: const Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF88844D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),              
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}