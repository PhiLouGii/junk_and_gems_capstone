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
  
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
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

  void _showUnavailableDialog(BuildContext context, String paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Coming Soon!'),
          ],
        ),
        content: Text(
          '$paymentMethod is currently not available. Please check back soon or use card payment.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedPaymentMethod = 'Card (Credit/Debit)';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF88844D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
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
            _buildHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isWideScreen = constraints.maxWidth > 700;
                  
                  if (isWideScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildPaymentOptions(),
                                const SizedBox(height: 20),
                                if (_selectedPaymentMethod == 'Card (Credit/Debit)')
                                  _buildCardPaymentForm(),
                                if (_selectedPaymentMethod == 'EcoCash')
                                  _buildMobilePaymentForm('EcoCash', _ecocashPhoneController),
                                if (_selectedPaymentMethod == 'M-Pesa')
                                  _buildMobilePaymentForm('M-Pesa', _mpesaPhoneController),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: _buildOrderSummary(),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildOrderSummary(),
                          const SizedBox(height: 20),
                          _buildPaymentOptions(),
                          const SizedBox(height: 20),
                          if (_selectedPaymentMethod == 'Card (Credit/Debit)')
                            _buildCardPaymentForm(),
                          if (_selectedPaymentMethod == 'EcoCash')
                            _buildMobilePaymentForm('EcoCash', _ecocashPhoneController),
                          if (_selectedPaymentMethod == 'M-Pesa')
                            _buildMobilePaymentForm('M-Pesa', _mpesaPhoneController),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            _buildBottomButton(),
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
            onPressed: () => Navigator.pop(context),
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
                  child: const Icon(Icons.payment, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
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
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: widget.cartItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item['title']} x${item['quantity']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'M${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSummaryRow('Subtotal', 'M${widget.subtotal.toStringAsFixed(2)}'),
          
          if (widget.gemsDiscount > 0) ...[
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
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '-M${widget.gemsDiscount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
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
                  'M${widget.total.toStringAsFixed(2)}',
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
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
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
                  Icons.payment,
                  color: Color(0xFF88844D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
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
          
          _buildPaymentOptionWithLogo(
            title: 'EcoCash',
            isSelected: _selectedPaymentMethod == 'EcoCash',
            onTap: () {
              _showUnavailableDialog(context, 'EcoCash');
            },
            logoPath: 'assets/images/ecocash_logo.png',
          ),
          const SizedBox(height: 12),
          
          _buildPaymentOptionWithLogo(
            title: 'M-Pesa',
            isSelected: _selectedPaymentMethod == 'M-Pesa',
            onTap: () {
              _showUnavailableDialog(context, 'M-Pesa');
            },
            logoPath: 'assets/images/mpesa_logo.png',
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFBEC092).withOpacity(0.2) 
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF88844D) 
                : const Color(0xFFBEC092).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF88844D) 
                    : const Color(0xFFBEC092).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF88844D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF88844D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionWithLogo({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required String logoPath,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFBEC092).withOpacity(0.2) 
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF88844D) 
                : const Color(0xFFBEC092).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                logoPath,
                height: 24,
                width: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF88844D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm() {
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
                  Icons.credit_card,
                  color: Color(0xFF88844D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Card Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            label: 'Card Number',
            controller: _cardNumberController,
            hintText: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Expiry Date',
                  controller: _expiryController,
                  hintText: 'MM/YY',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'CVC',
                  controller: _cvcController,
                  hintText: '123',
                  keyboardType: TextInputType.number,
                  icon: Icons.lock_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            label: 'Name on Card',
            controller: _nameController,
            hintText: 'John Doe',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBEC092).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 6),
                    Text(
                      'We Accept:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/visa_logo.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    Image.asset(
                      'assets/images/mastercard_logo.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePaymentForm(String provider, TextEditingController controller) {
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
                  Icons.phone_android,
                  color: Color(0xFF88844D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$provider Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBEC092), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEC092).withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    '+266',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'xxxx xxxx',
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFBEC092).withOpacity(0.2),
                  const Color(0xFF88844D).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBEC092).withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 8),
                    Text(
                      'How it works:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionStep('1', 'Enter your $provider registered phone number'),
                const SizedBox(height: 8),
                _buildInstructionStep('2', 'Confirm payment to receive a prompt'),
                const SizedBox(height: 8),
                _buildInstructionStep('3', 'Enter your $provider PIN to complete'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF88844D),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBEC092), width: 2),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF88844D),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
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
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _processPayment(context),
            icon: const Icon(Icons.lock_outline, size: 22),
            label: Text(
              'Confirm Payment • M${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF88844D),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Processing payment...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _showSuccessDialog(context);
    });
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF88844D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF88844D),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your order has been confirmed and will be delivered soon.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/marketplace',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF88844D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF88844D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}