import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/checkout_screen.dart';
import 'package:junk_and_gems/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/services/cart_service.dart';
import 'package:junk_and_gems/services/api_service.dart';

class ShoppingCartScreen extends StatefulWidget {
  final String userId;
  
  const ShoppingCartScreen({super.key, required this.userId});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  List<dynamic> _cartItems = [];
  int _availableGems = 0;
  int _appliedGems = 0;
  final TextEditingController _gemsController = TextEditingController();
  bool _isLoading = true;
  bool _hasAuthError = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    try {
      print('🔐 Checking authentication status...');
      final isLoggedIn = await ApiService.isLoggedIn();
      
      if (!isLoggedIn) {
        print('❌ User not logged in');
        setState(() {
          _hasAuthError = true;
          _isLoading = false;
        });
        return;
      }

      print('✅ User is logged in, loading cart data...');
      await _loadCartData();
      await CartService.testConnection();
    } catch (e) {
      print('❌ Auth check error: $e');
      setState(() {
        _hasAuthError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCartData() async {
    try {
      print('🛒 Loading cart data for user: ${widget.userId}');
      
      int userGems = 0;
      List<dynamic> cartItems = [];

      try {
        userGems = await CartService.getUserGems(widget.userId);
        print('💎 User gems loaded: $userGems');
      } catch (e) {
        print('⚠️ Could not load user gems: $e');
        userGems = 0;
        
        if (_isAuthError(e)) {
          _handleAuthError();
          return;
        }
      }

      try {
        cartItems = await CartService.getCartItems(widget.userId);
        print('✅ Cart items loaded: ${cartItems.length} items');
      } catch (e) {
        print('❌ Could not load cart items: $e');
        
        if (_isAuthError(e)) {
          _handleAuthError();
          return;
        }
      }

      setState(() {
        _cartItems = cartItems;
        _availableGems = userGems;
        _isLoading = false;
        _hasAuthError = false;
      });
      
    } catch (e) {
      print('❌ Unexpected error in _loadCartData: $e');
      setState(() {
        _isLoading = false;
      });
    }
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

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text('Please login to access your shopping cart.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _navigateToLogin();
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
      _showErrorSnackBar('Failed to update quantity: ${e.toString().replaceAll('Exception: ', '')}');
      
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
      _showErrorSnackBar('Failed to remove item: ${e.toString().replaceAll('Exception: ', '')}');
      
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
        _showWarningSnackBar('Maximum allowed gems is $maxAllowed (10% of your total)');
      } else if (gems > _availableGems) {
        _appliedGems = _availableGems;
        _gemsController.text = _availableGems.toString();
        _showWarningSnackBar('Cannot apply more gems than you have');
      } else {
        _appliedGems = gems;
        _showSuccessSnackBar('$gems gems applied successfully!');
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_hasAuthError || _isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryLoadData,
              tooltip: 'Retry',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildDebugButtons(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF88844D)),
            SizedBox(height: 16),
            Text('Loading your cart...'),
          ],
        ),
      );
    }

    if (_hasAuthError) {
      return _buildAuthErrorScreen();
    }

    if (_cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildCartItems(),
                const SizedBox(height: 24),
                _buildGemsSection(),
                const SizedBox(height: 24),
                _buildOrderSummary(),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildAuthErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please login to access your shopping cart and gems.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF88844D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Login Now'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _retryLoadData,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Retry'),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF88844D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Browse Marketplace'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return Column(
      children: _cartItems.map((item) {
        return Column(
          children: [
            _buildCartItem(item),
            if (_cartItems.indexOf(item) < _cartItems.length - 1) 
              Divider(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
                thickness: 1,
                height: 32,
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final imageUrl = (item['image_data_base64'] != null && 
                     item['image_data_base64'].isNotEmpty) 
        ? 'data:image/jpeg;base64,${item['image_data_base64'][0]}'
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE4E5C2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'] ?? 'Unknown Product',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'M${item['price'] ?? 0}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBEC092)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.remove, 
                            size: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          onPressed: () {
                            final newQuantity = (item['quantity'] ?? 1) - 1;
                            if (newQuantity >= 1) {
                              _updateQuantity(item['cart_item_id'].toString(), newQuantity);
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        Text(
                          (item['quantity'] ?? 1).toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add, 
                            size: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          onPressed: () {
                            final newQuantity = (item['quantity'] ?? 1) + 1;
                            _updateQuantity(item['cart_item_id'].toString(), newQuantity);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () {
                      _showDeleteDialog(item);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE4E5C2),
      child: Icon(
        Icons.shopping_bag,
        size: 30,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Are you sure you want to remove "${item['title']}" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeItem(item['cart_item_id'].toString());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildGemsSection() {
    final maxAllowed = _maxAllowedGems;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Apply Gems',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              children: [
                const TextSpan(text: 'You have '),
                TextSpan(
                  text: '$_availableGems Gems',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const TextSpan(text: ' available\n'),
                TextSpan(
                  text: 'Maximum allowed: $maxAllowed Gems (10% of total)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const TextSpan(text: '\n(100 Gems = M100)'),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBEC092)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _gemsController,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        hintText: 'Enter amount of Gems (max: $maxAllowed)',
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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
                          });
                        } else if (gems > _availableGems) {
                          setState(() {
                            _appliedGems = _availableGems;
                            _gemsController.text = _availableGems.toString();
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
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFBEC092),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: _applyGems,
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildSummaryRow('Subtotal', 'M${_subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          if (_appliedGems > 0)
            Column(
              children: [
                _buildSummaryRow('Gems Applied', '-M${_appliedGems.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
              ],
            ),
          _buildSummaryRow(
            'Total',
            'M${_total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                side: BorderSide(color: const Color(0xFFBEC092)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add more items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        cartItems: _cartItems.cast<Map<String, dynamic>>(),
                        subtotal: _subtotal,
                        gemsDiscount: _appliedGems.toDouble(),
                        total: _total,
                      ),
                    ),
                  ).then((_) {
                    _loadCartData();
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Checkout',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "debug1",
          mini: true,
          onPressed: () async {
            print('🐛 DEBUG: Testing cart connection...');
            try {
              await CartService.testConnection();
              final token = await ApiService.getToken();
              print('🔐 Current token: $token');
              _showSuccessSnackBar('Connection test completed');
            } catch (e) {
              _showErrorSnackBar('Connection test failed: $e');
            }
          },
          child: const Icon(Icons.bug_report),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "debug2",
          mini: true,
          onPressed: _retryLoadData,
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _gemsController.dispose();
    super.dispose();
  }
}