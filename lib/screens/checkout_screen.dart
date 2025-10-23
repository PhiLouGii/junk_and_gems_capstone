import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double gemsDiscount;
  final double total;
  final String userId;
  final String token;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.gemsDiscount,
    required this.total,
    required this.userId,
    required this.token,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Card (Credit/Debit)';
  
  // Card payment controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  // COD controllers
  final TextEditingController _codAddressController = TextEditingController();
  final TextEditingController _codPhoneController = TextEditingController();
  final TextEditingController _codNotesController = TextEditingController();
  
  // USSD selected bank
  String _selectedUssdBank = 'Standard Lesotho Bank';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    _codAddressController.dispose();
    _codPhoneController.dispose();
    _codNotesController.dispose();
    super.dispose();
  }

  double get finalTotal {
    if (_selectedPaymentMethod == 'Cash on Delivery') {
      return widget.total + 20; // Add M20 COD fee
    }
    return widget.total;
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
                                _buildPaymentForm(),
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
                          _buildPaymentForm(),
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

          // Show COD fee if selected
          if (_selectedPaymentMethod == 'Cash on Delivery') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Delivery Fee',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '+M20.00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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
                  'M${finalTotal.toStringAsFixed(2)}',
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
          
          _buildPaymentOption(
            title: 'Cash on Delivery',
            subtitle: '+M20 delivery fee',
            isSelected: _selectedPaymentMethod == 'Cash on Delivery',
            onTap: () {
              setState(() {
                _selectedPaymentMethod = 'Cash on Delivery';
              });
            },
            icon: Icons.delivery_dining,
          ),
          const SizedBox(height: 12),
          
          _buildPaymentOption(
            title: 'USSD Payment',
            subtitle: 'Dial from your phone',
            isSelected: _selectedPaymentMethod == 'USSD Payment',
            onTap: () {
              setState(() {
                _selectedPaymentMethod = 'USSD Payment';
              });
            },
            icon: Icons.phone_android,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    String? subtitle,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'Card (Credit/Debit)':
        return _buildCardPaymentForm();
      case 'Cash on Delivery':
        return _buildCODForm();
      case 'USSD Payment':
        return _buildUSSDForm();
      default:
        return const SizedBox.shrink();
    }
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
        ],
      ),
    );
  }

  Widget _buildCODForm() {
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
                  Icons.delivery_dining,
                  color: Color(0xFF88844D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delivery Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.1),
                  Colors.orange.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pay M${finalTotal.toStringAsFixed(2)} when your order is delivered',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            label: 'Full Delivery Address',
            controller: _codAddressController,
            hintText: 'House number, street, area, city',
            icon: Icons.location_on,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            label: 'Phone Number',
            controller: _codPhoneController,
            hintText: '+266 XXXX XXXX',
            keyboardType: TextInputType.phone,
            icon: Icons.phone,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            label: 'Delivery Notes (Optional)',
            controller: _codNotesController,
            hintText: 'Any special instructions...',
            icon: Icons.note,
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          
          // How it works section
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Color(0xFF88844D)),
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
                _buildInstructionStep('1', 'We confirm your order and prepare it'),
                const SizedBox(height: 8),
                _buildInstructionStep('2', 'Our driver calls you to arrange delivery'),
                const SizedBox(height: 8),
                _buildInstructionStep('3', 'Pay cash when you receive your items'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUSSDForm() {
    final ussdCodes = {
      'Standard Lesotho Bank': '*150#',
      'Nedbank': '*120*3333#',
      'FNB': '*120*321#',
    };

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
                'USSD Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Bank selection
          Text(
            'Select Your Bank',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          
          ...ussdCodes.keys.map((bank) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedUssdBank = bank;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedUssdBank == bank
                      ? const Color(0xFFBEC092).withOpacity(0.2)
                      : Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedUssdBank == bank
                        ? const Color(0xFF88844D)
                        : const Color(0xFFBEC092).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: _selectedUssdBank == bank
                          ? const Color(0xFF88844D)
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bank,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: _selectedUssdBank == bank
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    if (_selectedUssdBank == bank)
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
            ),
          )),
          
          const SizedBox(height: 20),
          
          // USSD Code Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF88844D).withOpacity(0.1),
                  const Color(0xFFBEC092).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBEC092).withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.dialpad, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 8),
                    Text(
                      'Dial this code on your phone:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ussdCodes[_selectedUssdBank]!,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF88844D),
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: ussdCodes[_selectedUssdBank]!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('USSD code copied!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, color: Color(0xFF88844D)),
                      tooltip: 'Copy code',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Instructions
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 8),
                    Text(
                      'How to pay:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionStep('1', 'Dial ${ussdCodes[_selectedUssdBank]} from your phone'),
                const SizedBox(height: 8),
                _buildInstructionStep('2', 'Select "Pay Merchant" or "Make Payment"'),
                const SizedBox(height: 8),
                _buildInstructionStep('3', 'Enter merchant code: 12345'),
                const SizedBox(height: 8),
                _buildInstructionStep('4', 'Enter amount: M${finalTotal.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _buildInstructionStep('5', 'Enter your PIN to confirm'),
                const SizedBox(height: 8),
                _buildInstructionStep('6', 'Come back and confirm your order'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Important note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your order will be confirmed once we verify your USSD payment',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value, {bool canCopy = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (canCopy) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(Icons.copy, size: 16, color: Color(0xFF88844D)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF88844D),
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
    int maxLines = 1,
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
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  top: maxLines > 1 ? 12 : 0,
                ),
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
                  maxLines: maxLines,
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
              'Confirm Order • M${finalTotal.toStringAsFixed(2)}',
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

  void _processPayment(BuildContext context) async {
    // Validate based on payment method
    if (_selectedPaymentMethod == 'Card (Credit/Debit)') {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvcController.text.isEmpty ||
          _nameController.text.isEmpty) {
        _showErrorDialog(context, 'Please fill in all card details');
        return;
      }
    } else if (_selectedPaymentMethod == 'Cash on Delivery') {
      if (_codAddressController.text.isEmpty) {
        _showErrorDialog(context, 'Please enter your delivery address');
        return;
      }
      if (_codPhoneController.text.isEmpty) {
        _showErrorDialog(context, 'Please enter your phone number');
        return;
      }
    }

    // Show processing dialog
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
                'Processing order...',
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

    try {
      // Prepare order data
      String paymentMethodCode = _selectedPaymentMethod == 'Card (Credit/Debit)' ? 'card'
          : _selectedPaymentMethod == 'Cash on Delivery' ? 'cod'
          : _selectedPaymentMethod == 'Bank Transfer' ? 'bank_transfer'
          : 'ussd';

      final orderData = {
        'cartItems': widget.cartItems,
        'totalAmount': widget.subtotal,
        'appliedGems': widget.gemsDiscount,
        'paymentMethod': paymentMethodCode,
        'deliveryAddress': _codAddressController.text,
        'phoneNumber': _codPhoneController.text,
      };

      // Call backend API
      final response = await http.post(
        Uri.parse('https://your-render-url.onrender.com/api/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode(orderData),
      );

      Navigator.pop(context); // Close processing dialog

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _showSuccessDialog(context, paymentMethodCode);
      } else {
        final error = json.decode(response.body);
        _showErrorDialog(context, error['error'] ?? 'Order creation failed');
      }
    } catch (e) {
      Navigator.pop(context); // Close processing dialog
      _showErrorDialog(context, 'Network error: ${e.toString()}');
    }
  }

  void _showSuccessDialog(BuildContext context, String paymentMethod) {
    String message = '';
    String title = '';
    
    switch (paymentMethod) {
      case 'cod':
        title = 'Order Confirmed!';
        message = 'Your order has been placed. We\'ll call you to arrange delivery. Pay M${finalTotal.toStringAsFixed(2)} on delivery.';
        break;
      case 'bank_transfer':
        title = 'Order Pending';
        message = 'Your order is pending payment verification. We\'ll confirm once we verify your bank transfer.';
        break;
      case 'ussd':
        title = 'Order Pending';
        message = 'Your order is pending payment confirmation. We\'ll process it once your USSD payment is verified.';
        break;
      default:
        title = 'Payment Successful!';
        message = 'Your order has been confirmed and will be delivered soon.';
    }

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
              child: Icon(
                paymentMethod == 'card' ? Icons.check_circle : Icons.schedule,
                color: const Color(0xFF88844D),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
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