import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';

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
  
  // Mobile payment form controllers
  final TextEditingController _ecocashPhoneController = TextEditingController();
  final TextEditingController _mpesaPhoneController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    _ecocashPhoneController.dispose();
    _mpesaPhoneController.dispose();
    super.dispose();
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
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
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
            _buildOrderSummary(isDarkMode),
            const SizedBox(height: 32),
            
            // Payment Options Section
            _buildPaymentOptions(isDarkMode),
            const SizedBox(height: 32),
            
            // Card Payment Form (only visible when card is selected)
            if (_selectedPaymentMethod == 'Card (Credit/Debit)')
              _buildCardPaymentForm(isDarkMode),
            
            // EcoCash Payment Form (only visible when EcoCash is selected)
            if (_selectedPaymentMethod == 'EcoCash')
              _buildEcoCashPaymentForm(isDarkMode),
            
            // M-Pesa Payment Form (only visible when M-Pesa is selected)
            if (_selectedPaymentMethod == 'M-Pesa')
              _buildMPesaPaymentForm(isDarkMode),
          ],
        ),
      ),
      
      // Confirm Payment Button
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.all(20),
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
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
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
            child: Text(
              'Confirm Payment',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
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
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                        ),
                      ),
                    ),
                    Text(
                      'M${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          
          Divider(
            color: Theme.of(context).colorScheme.secondary,
            thickness: 1,
            height: 24,
          ),
          
          // Subtotal
          _buildSummaryRow('Subtotal', 'M${widget.subtotal.toStringAsFixed(2)}', isDarkMode),
          const SizedBox(height: 8),
          
          // Gems Discount
          if (widget.gemsDiscount > 0)
            Column(
              children: [
                _buildSummaryRow('Gems Discount', '-M${widget.gemsDiscount.toStringAsFixed(2)}', isDarkMode),
                const SizedBox(height: 8),
              ],
            ),
          
          // Total
          _buildSummaryRow(
            'Total',
            'M${widget.total.toStringAsFixed(2)}',
            isDarkMode,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDarkMode, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDarkMode ? Colors.white : const Color(0xFF88844D),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDarkMode ? Colors.white : const Color(0xFF88844D),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
            'Payment Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
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
            isDarkMode: isDarkMode,
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
            isDarkMode: isDarkMode,
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
            isDarkMode: isDarkMode,
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
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.secondary.withOpacity(0.3) : 
                 isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.secondary : 
                   Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isDarkMode ? Colors.white : const Color(0xFF88844D),
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
            'Card Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
            ),
          ),
          const SizedBox(height: 16),
          
          // Card Number
          _buildCardTextField(
            label: 'Card Number',
            controller: _cardNumberController,
            hintText: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
            isDarkMode: isDarkMode,
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
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCardTextField(
                  label: 'CVC',
                  controller: _cvcController,
                  hintText: '123',
                  keyboardType: TextInputType.number,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Name on Card
          _buildCardTextField(
            label: 'Name on Card',
            controller: _nameController,
            hintText: 'Mahloli Makhetha',
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          
          // Accepted Cards
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We Accept:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : const Color(0xFF88844D),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PaymentLogo(text: 'VISA', isDarkMode: isDarkMode),
                  const SizedBox(width: 12),
                  _PaymentLogo(text: 'Mastercard', isDarkMode: isDarkMode),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEcoCashPaymentForm(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
            'EcoCash Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
            ),
          ),
          const SizedBox(height: 16),
          
          // Phone Number Input
          _buildMobileTextField(
            label: 'EcoCash Phone Number',
            controller: _ecocashPhoneController,
            hintText: 'xxxx xxxx',
            keyboardType: TextInputType.phone,
            prefixText: '+266 ',
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F2E4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.secondary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1. Enter your EcoCash registered phone number\n2. Confirm payment to receive a prompt\n3. Enter your EcoCash PIN to complete payment',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF88844D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMPesaPaymentForm(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
            'M-Pesa Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
            ),
          ),
          const SizedBox(height: 16),
          
          // Phone Number Input
          _buildMobileTextField(
            label: 'M-Pesa Phone Number',
            controller: _mpesaPhoneController,
            hintText: 'xxxx xxxx',
            keyboardType: TextInputType.phone,
            prefixText: '+266 ',
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F2E4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.secondary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1. Enter your M-Pesa registered phone number\n2. Confirm payment to receive a prompt\n3. Enter your M-Pesa PIN to complete payment',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF88844D),
                  ),
                ),
              ],
            ),
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
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F2E4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xFF88844D),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF88844D).withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required String prefixText,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F2E4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  prefixText,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : const Color(0xFF88844D).withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _processPayment(BuildContext context) {
    // Validate form based on selected payment method
    if (_selectedPaymentMethod == 'Card (Credit/Debit)') {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvcController.text.isEmpty ||
          _nameController.text.isEmpty) {
        _showErrorDialog(context, 'Please fill in all card details');
        return;
      }
    } else if (_selectedPaymentMethod == 'EcoCash') {
      if (_ecocashPhoneController.text.isEmpty) {
        _showErrorDialog(context, 'Please enter your EcoCash phone number');
        return;
      }
    } else if (_selectedPaymentMethod == 'M-Pesa') {
      if (_mpesaPhoneController.text.isEmpty) {
        _showErrorDialog(context, 'Please enter your M-Pesa phone number');
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
      _showSuccessDialog(context);
    });
  }

  void _showSuccessDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F2E4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
            ),
            const SizedBox(width: 8),
            Text(
              'Payment Successful!',
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Your order has been confirmed and will be delivered soon.',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF88844D),
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
            child: Text(
              'Continue Shopping',
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F2E4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
            ),
            const SizedBox(width: 8),
            Text(
              'Error',
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF88844D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for payment logos
class _PaymentLogo extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const _PaymentLogo({required this.text, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F2E4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
        ),
      ),
    );
  }
}