import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double gemsDiscount;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.gemsDiscount,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Card (Credit/Debit)';
  
  // Card payment form controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
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
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Section
            _buildOrderSummary(),
            const SizedBox(height: 32),
            
            // Payment Options Section
            _buildPaymentOptions(),
            const SizedBox(height: 32),
            
            // Card Payment Form (only visible when card is selected)
            if (_selectedPaymentMethod == 'Card (Credit/Debit)')
              _buildCardPaymentForm(),
          ],
        ),
      ),
      
      // Confirm Payment Button
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.all(20),
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
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFBEC092),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () {
              _processPayment(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm Payment',
              style: TextStyle(
                color: Color(0xFF88844D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF88844D),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cart Items List
          Column(
            children: widget.cartItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item['title']} x${item['quantity']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF88844D),
                        ),
                      ),
                    ),
                    Text(
                      'M${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF88844D),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          
          const Divider(
            color: Color(0xFFBEC092),
            thickness: 1,
            height: 24,
          ),
          
          // Subtotal
          _buildSummaryRow('Subtotal', 'M${widget.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          
          // Gems Discount
          if (widget.gemsDiscount > 0)
            Column(
              children: [
                _buildSummaryRow('Gems Discount', '-M${widget.gemsDiscount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
              ],
            ),
          
          // Total
          _buildSummaryRow(
            'Total',
            'M${widget.total.toStringAsFixed(2)}',
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
            color: const Color(0xFF88844D),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF88844D),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Payment Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF88844D),
            ),
          ),
          const SizedBox(height: 16),
          
          // Card Payment Option
          _buildPaymentOption(
            title: 'Card (Credit/Debit)',
            isSelected: _selectedPaymentMethod == 'Card (Credit/Debit)',
            onTap: () {
              setState(() {
                _selectedPaymentMethod = 'Card (Credit/Debit)';
              });
            },
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 12),
          
          // EcoCash Payment Option
          _buildPaymentOption(
            title: 'EcoCash',
            isSelected: _selectedPaymentMethod == 'EcoCash',
            onTap: () {
              setState(() {
                _selectedPaymentMethod = 'EcoCash';
              });
            },
            icon: Icons.phone_android,
          ),
          const SizedBox(height: 12),
          
          // M-Pesa Payment Option
          _buildPaymentOption(
            title: 'M-Pesa',
            isSelected: _selectedPaymentMethod == 'M-Pesa',
            onTap: () {
              setState(() {
                _selectedPaymentMethod = 'M-Pesa';
              });
            },
            icon: Icons.mobile_friendly,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBEC092).withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFBEC092) : const Color(0xFFBEC092).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF88844D),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF88844D),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF88844D),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Card Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF88844D),
            ),
          ),
          const SizedBox(height: 16),
          
          // Card Number
          _buildCardTextField(
            label: 'Card Number',
            controller: _cardNumberController,
            hintText: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Expiry and CVC in one row
          Row(
            children: [
              Expanded(
                child: _buildCardTextField(
                  label: 'MM/YY',
                  controller: _expiryController,
                  hintText: 'MM/YY',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCardTextField(
                  label: 'CVC',
                  controller: _cvcController,
                  hintText: '123',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Name on Card
          _buildCardTextField(
            label: 'Name on Card',
            controller: _nameController,
            hintText: 'John Doe',
          ),
          const SizedBox(height: 16),
          
          // Accepted Cards
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We Accept:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF88844D),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  // Visa logo (using text as placeholder)
                  _PaymentLogo(text: 'VISA'),
                  SizedBox(width: 12),
                  // Mastercard logo (using text as placeholder)
                  _PaymentLogo(text: 'Mastercard'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F2E4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBEC092)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: const Color(0xFF88844D).withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _processPayment(BuildContext context) {
    // Validate card details if card payment is selected
    if (_selectedPaymentMethod == 'Card (Credit/Debit)') {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvcController.text.isEmpty ||
          _nameController.text.isEmpty) {
        _showErrorDialog(context, 'Please fill in all card details');
        return;
      }
    }

    // Show loading or processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF88844D),
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Remove loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFF7F2E4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF88844D),
              ),
              SizedBox(width: 8),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  color: Color(0xFF88844D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your order has been confirmed and will be shipped soon.',
            style: TextStyle(
              color: Color(0xFF88844D),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate back to marketplace and clear the cart
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/marketplace',
                  (route) => false,
                );
              },
              child: const Text(
                'Continue Shopping',
                style: TextStyle(
                  color: Color(0xFF88844D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF7F2E4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error,
              color: Color(0xFF88844D),
            ),
            SizedBox(width: 8),
            Text(
              'Error',
              style: TextStyle(
                color: Color(0xFF88844D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF88844D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF88844D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for payment logos (using text as placeholder - replace with actual images if available)
class _PaymentLogo extends StatelessWidget {
  final String text;

  const _PaymentLogo({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBEC092)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF88844D),
        ),
      ),
    );
  }
}