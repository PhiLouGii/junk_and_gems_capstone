import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int _canTabLampQuantity = 1;
  int _denimBagQuantity = 2;
  int _availableGems = 840;
  int _appliedGems = 0;
  final TextEditingController _gemsController = TextEditingController();

  final List<Map<String, dynamic>> _cartItems = [
    {
    'title': 'Sta-Soft Lamp',
    'price': 400,
    'image': 'assets/images/featured3.jpg',
    'quantity': 1,
    },
    {
      'title': 'Can Tab Lamp',
      'price': 650,
      'image': 'assets/images/featured6.jpg',
      'quantity': 1,
    },
    {
      'title': 'Denim Patchwork Bag',
      'price': 330,
      'image': 'assets/images/upcycled1.jpg',
      'quantity': 2,
    },
  ];

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double get _total {
    final gemDiscount = _appliedGems; // 100 Gems = M100, so 1 Gem = M1
    return _subtotal - gemDiscount;
  }

  @override
  void initState() {
    super.initState();
    // Initialize with current quantities
    _cartItems[0]['quantity'] = _canTabLampQuantity;
    _cartItems[1]['quantity'] = _denimBagQuantity;
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Cart Items
                  _buildCartItems(),
                  const SizedBox(height: 24),
                  
                  // Apply Gems Section
                  _buildGemsSection(),
                  const SizedBox(height: 24),
                  
                  // Order Summary
                  _buildOrderSummary(),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
          _buildBottomButtons(),
        ],
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
            _buildCartItem(
              title: item['title'],
              price: item['price'],
              image: item['image'],
              quantity: item['quantity'],
              onQuantityChanged: (newQuantity) {
                setState(() {
                  _cartItems[index]['quantity'] = newQuantity;
                  if (index == 0) _canTabLampQuantity = newQuantity;
                  if (index == 1) _denimBagQuantity = newQuantity;
                });
              },
            ),
            if (index < _cartItems.length - 1) 
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

  Widget _buildCartItem({
    required String title,
    required int price,
    required String image,
    required int quantity,
    required Function(int) onQuantityChanged,
  }) {
    return Row(
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
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE4E5C2),
                  child: Icon(
                    Icons.shopping_bag,
                    size: 30,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Product Details and Quantity
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'M$price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              
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
                        if (quantity > 1) {
                          onQuantityChanged(quantity - 1);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    Text(
                      quantity.toString(),
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
                        onQuantityChanged(quantity + 1);
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
      ],
    );
  }

  Widget _buildGemsSection() {
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
                          // Ensure applied gems don't exceed available gems
                          if (_appliedGems > _availableGems) {
                            _appliedGems = _availableGems;
                            _gemsController.text = _availableGems.toString();
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
                    setState(() {
                      _appliedGems = gems > _availableGems ? _availableGems : gems;
                      _gemsController.text = _appliedGems.toString();
                    });
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
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  // Navigate to checkout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        cartItems: _cartItems,
                        subtotal: _subtotal,
                        gemsDiscount: _appliedGems.toDouble(),
                        total: _total,
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