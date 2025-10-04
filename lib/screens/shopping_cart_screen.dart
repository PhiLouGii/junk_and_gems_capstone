import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/providers/cart_provider.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final TextEditingController _gemsController = TextEditingController();
  int _appliedGems = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // We can't use Provider in initState directly, so we use WidgetsBinding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartData();
    });
  }

  void _loadCartData() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      cartProvider.fetchCart(); // Remove the parameter - fetchCart doesn't take userId
      setState(() {
        _isInitialized = true;
      });
    }
  }

  double get _subtotal {
    final cartProvider = Provider.of<CartProvider>(context);
    return cartProvider.subtotal;
  }

  double get _total {
    final gemDiscount = _appliedGems.toDouble();
    return _subtotal - gemDiscount;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
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
      ),
      body: !_isInitialized && authProvider.isAuthenticated
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Cart Items
                        _buildCartItems(cartProvider),
                        const SizedBox(height: 24),
                        
                        // Apply Gems Section
                        _buildGemsSection(authProvider),
                        const SizedBox(height: 24),
                        
                        // Order Summary
                        _buildOrderSummary(),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Buttons
                _buildBottomButtons(cartProvider),
              ],
            ),
    );
  }

  Widget _buildCartItems(CartProvider cartProvider) {
    if (cartProvider.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (cartProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error loading cart',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 8),
              Text(
                cartProvider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  cartProvider.clearError();
                  _loadCartData();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (cartProvider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add some items to get started',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: cartProvider.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return Column(
          children: [
            _buildCartItem(item, cartProvider),
            if (index < cartProvider.items.length - 1) 
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

  Widget _buildCartItem(CartItem item, CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E5C2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderIcon();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : _buildPlaceholderIcon(),
            ),
          ),
          const SizedBox(width: 16),
          
          // Product Details and Quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'M${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Quantity Selector
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
                          if (item.quantity > 1) {
                            cartProvider.updateCartItemQuantity(
                              item.id!, 
                              item.quantity - 1
                            );
                          } else {
                            cartProvider.removeFromCart(item.id!);
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      Text(
                        item.quantity.toString(),
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
                          cartProvider.updateCartItemQuantity(
                            item.id!, 
                            item.quantity + 1
                          );
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
              ],
            ),
          ),
          
          // Remove button
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () {
              _showDeleteConfirmation(item, cartProvider);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(CartItem item, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Item'),
          content: Text('Are you sure you want to remove ${item.title} from your cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.removeFromCart(item.id!);
                Navigator.of(context).pop();
              },
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: const Color(0xFFE4E5C2),
      child: Icon(
        Icons.shopping_bag,
        size: 30,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildGemsSection(AuthProvider authProvider) {
    final availableGems = authProvider.user?.availableGems ?? 0;
    
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
                  text: '$availableGems Gems',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const TextSpan(text: ' available\n'),
                const TextSpan(text: '(100 Gems = M100)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Gems Input Field
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
                        hintText: 'Enter amount of Gems',
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _appliedGems = int.tryParse(value) ?? 0;
                          // Ensure applied gems don't exceed available gems or subtotal
                          if (_appliedGems > availableGems) {
                            _appliedGems = availableGems;
                            _gemsController.text = availableGems.toString();
                          }
                          
                          // Ensure applied gems don't exceed subtotal
                          final maxApplicableGems = _subtotal.toInt();
                          if (_appliedGems > maxApplicableGems) {
                            _appliedGems = maxApplicableGems;
                            _gemsController.text = maxApplicableGems.toString();
                          }
                        });
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
                  onPressed: () {
                    // Apply the gems
                    final gems = int.tryParse(_gemsController.text) ?? 0;
                    final availableGems = authProvider.user?.availableGems ?? 0;
                    final maxApplicableGems = _subtotal.toInt();
                    
                    setState(() {
                      _appliedGems = gems.clamp(0, availableGems).clamp(0, maxApplicableGems);
                      _gemsController.text = _appliedGems.toString();
                    });
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Applied $_appliedGems gems to your order'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
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
          if (_appliedGems > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Applied $_appliedGems gems (M${_appliedGems.toStringAsFixed(2)} discount)',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final cartProvider = Provider.of<CartProvider>(context);
    
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
          _buildSummaryRow('Subtotal (${cartProvider.totalItems} items)', 'M${_subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          if (_appliedGems > 0)
            Column(
              children: [
                _buildSummaryRow('Gems Applied', '-M${_appliedGems.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
              ],
            ),
          const Divider(),
          const SizedBox(height: 8),
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

  Widget _buildBottomButtons(CartProvider cartProvider) {
    final authProvider = Provider.of<AuthProvider>(context);
    
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
          // Add More Items Button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to marketplace
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
          
          // Checkout Button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cartProvider.items.isEmpty || !authProvider.isAuthenticated 
                    ? Colors.grey 
                    : const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: cartProvider.items.isEmpty || !authProvider.isAuthenticated ? null : () {
                  // Navigate to checkout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        cartItems: cartProvider.items,
                        subtotal: _subtotal,
                        gemsDiscount: _appliedGems.toDouble(),
                        total: _total,
                        appliedGems: _appliedGems,
                      ),
                    ),
                  );
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

  @override
  void dispose() {
    _gemsController.dispose();
    super.dispose();
  }
}