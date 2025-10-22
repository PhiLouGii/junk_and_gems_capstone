import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Formatter for Card Number (XXXX XXXX XXXX XXXX)
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(' ', '');

    if (newText.length > 16) {
      return oldValue;
    }

    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      formattedText += newText[i];
      if ((i + 1) % 4 == 0 && i != newText.length - 1) {
        formattedText += ' ';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Formatter for Expiry Date (MM/YY)
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll('/', '');

    if (newText.length > 4) {
      return oldValue;
    }

    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      formattedText += newText[i];
      if (i == 1 && i != newText.length - 1) {
        formattedText += '/';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// -----------------------------------------------------------------

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
  
  // Bank Transfer controllers
  final TextEditingController _bankReferenceController = TextEditingController();
  
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
    _bankReferenceController.dispose();
    super.dispose();
  }

  double get finalTotal {
    if (_selectedPaymentMethod == 'Cash on Delivery') {
      return widget.total + 20; // Add M20 COD fee
    }
    return widget.total;
  }

  // --- Payment Processing Logic ---

  void _processPayment(BuildContext context) async {
    // 1. Validation
    if (_selectedPaymentMethod == 'Card (Credit/Debit)') {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvcController.text.isEmpty ||
          _nameController.text.isEmpty) {
        _showErrorDialog(context, 'Please fill in all card details correctly.');
        return;
      }
    } else if (_selectedPaymentMethod == 'Cash on Delivery') {
      if (_codAddressController.text.isEmpty || _codPhoneController.text.isEmpty) {
        _showErrorDialog(context, 'Please enter a delivery address and a contact phone number.');
        return;
      }
      if (_codPhoneController.text.length != 8) {
        _showErrorDialog(context, 'Please enter a valid 8-digit phone number.');
        return;
      }
    } else if (_selectedPaymentMethod == 'Bank Transfer') {
      if (_bankReferenceController.text.isEmpty) {
        _showErrorDialog(context, 'Please ensure you have initiated the bank transfer and enter a payment reference.');
        return;
      }
    } 
    // USSD Payment doesn't require a local field check

    // 2. Show Loading Indicator
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

    // 3. API Call Logic 
    try {
      final response = await http.post(
        Uri.parse('YOUR_API_ENDPOINT/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}', 
        },
        body: json.encode({
          'userId': widget.userId,
          'cartItems': widget.cartItems,
          'paymentMethod': _selectedPaymentMethod,
          'totalAmount': finalTotal,
          'details': _getPaymentDetails(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context); // Dismiss loading dialog
        _showSuccessDialog(context);
      } else {
        Navigator.pop(context); // Dismiss loading dialog
        _showErrorDialog(context, 'Payment submission failed. Please try again or contact support. Status: ${response.statusCode}');
      }

    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      _showErrorDialog(context, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Map<String, dynamic> _getPaymentDetails() {
    if (_selectedPaymentMethod == 'Card (Credit/Debit)') {
      return {
        'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
        'expiryDate': _expiryController.text,
        'cvc': _cvcController.text,
        'cardHolderName': _nameController.text,
      };
    } else if (_selectedPaymentMethod == 'Cash on Delivery') {
      return {
        'deliveryAddress': _codAddressController.text,
        'contactPhone': '+266${_codPhoneController.text}',
        'notes': _codNotesController.text,
      };
    } else if (_selectedPaymentMethod == 'Bank Transfer') {
      return {
        'bankReference': _bankReferenceController.text,
        'bankName': 'Lesotho National Bank',
      };
    } else if (_selectedPaymentMethod == 'USSD Payment') {
      return {
        'selectedBank': _selectedUssdBank,
      };
    }
    return {};
  }

  // --- Dialog Helpers ---

  void _showSuccessDialog(BuildContext context) { // <-- FIXED: Added missing success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF88844D)),
            const SizedBox(width: 8),
            const Text('Order Placed!'),
          ],
        ),
        content: const Text(
            'Your order has been placed successfully and is awaiting processing. You will receive an email confirmation shortly.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Dismiss alert
              Navigator.of(context).popUntil((route) => route.isFirst); // Go back to main screen/homepage
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF88844D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
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

  // --- Build Methods (Truncated for brevity, assuming existing correct code) ---

  @override
  Widget build(BuildContext context) {
    // ... existing build method
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
      // ... existing code
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      // ... existing code
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      // ... existing code
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      // ... existing code
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
      // ... existing code
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'Card (Credit/Debit)':
        return _buildCardPaymentForm();
      case 'Cash on Delivery':
        return _buildCODForm();
      case 'Bank Transfer':
        return _buildBankTransferForm();
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(), // <-- Corrected
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Expiry Date',
                  controller: _expiryController,
                  hintText: 'MM/YY',
                  keyboardType: TextInputType.datetime,
                  icon: Icons.calendar_today,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpiryDateInputFormatter(), // <-- Corrected
                  ],
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
                  isObscure: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
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
            textCapitalization: TextCapitalization.words,
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
                    // Assuming you have these assets
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
          _buildFormHeader('Cash on Delivery', Icons.delivery_dining, Colors.orange),
          const SizedBox(height: 20),

          // COD Fee Reminder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A M20.00 delivery fee is added to your total for this payment method.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Delivery Address',
            controller: _codAddressController,
            hintText: 'e.g., House 123, Maseru West',
            icon: Icons.location_on_outlined,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Contact Phone Number',
            controller: _codPhoneController,
            hintText: 'e.g., 5xxxxxxx',
            keyboardType: TextInputType.phone,
            icon: Icons.phone_android,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Delivery Notes (Optional)',
            controller: _codNotesController,
            hintText: 'e.g., Leave package with security guard',
            icon: Icons.note_alt_outlined,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferForm() {
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
          _buildFormHeader('Bank Transfer Details', Icons.account_balance),
          const SizedBox(height: 20),

          // Bank Account Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBEC092), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBankDetailRow('Bank Name', 'Lesotho National Bank'),
                _buildBankDetailRow('Account Name', 'Junk & Gems PTY LTD'),
                _buildBankDetailRow('Account Number', '0123456789 (Cheque)'),
                _buildBankDetailRow('Branch Code', '990101'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            label: 'Payment Reference',
            controller: _bankReferenceController,
            hintText: 'Your bank transaction reference number',
            icon: Icons.receipt_long,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          
          Text(
            'Important:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use your Order ID (you will receive this after confirmation) as the reference. Your order will only be processed once the transfer is confirmed (can take up to 24 hours).',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUSSDForm() {
    final List<String> ussdBanks = ['Standard Lesotho Bank', 'Nedbank Lesotho', 'First National Bank'];
    
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
          _buildFormHeader('USSD Payment', Icons.phone_android),
          const SizedBox(height: 20),

          Text(
            'Select your bank',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBEC092), width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedUssdBank,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF88844D)),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                dropdownColor: Theme.of(context).cardColor,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUssdBank = newValue!;
                  });
                },
                items: ussdBanks.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // USSD Instructions
          _buildUSSDInstructions(
            bank: _selectedUssdBank,
            amount: finalTotal.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }

  Widget _buildUSSDInstructions({required String bank, required String amount}) {
    String ussdCode;
    String instruction;
    
    switch (bank) {
      case 'Standard Lesotho Bank':
        ussdCode = '*120*101#';
        instruction = 'Enter the merchant code (777777), amount (M$amount), and your PIN. Your order ID will be the reference.';
        break;
      case 'Nedbank Lesotho':
        ussdCode = '*140*101#';
        instruction = 'Follow the prompts for Nedbank\'s merchant payment service, entering the merchant ID, amount (M$amount), and confirming with your PIN.';
        break;
      case 'First National Bank':
        ussdCode = '*130*321#';
        instruction = 'Select "Pay Merchant", enter the merchant number, amount (M$amount), and confirm with your FNB PIN.';
        break;
      default:
        ussdCode = 'N/A';
        instruction = 'Select a bank to see USSD instructions.';
    }

    return Container(
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
              const Icon(Icons.mobile_friendly, size: 16, color: Color(0xFF88844D)),
              const SizedBox(width: 8),
              Text(
                'Steps for $bank:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'Dial the USSD code:'), // <-- Corrected
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF88844D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                ussdCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('2', instruction), // <-- Corrected
          const SizedBox(height: 8),
          _buildInstructionStep('3', 'Wait for confirmation from your bank. You will receive an Order ID after pressing "Confirm Payment".'), // <-- Corrected
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String instruction) { // <-- FIXED: Added missing helper
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF88844D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            instruction,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormHeader(String title, IconData icon, [Color? iconColor]) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFFBEC092)).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFF88844D),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool isObscure = false,
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
                  obscureText: isObscure,
                  inputFormatters: inputFormatters,
                  maxLines: maxLines,
                  textCapitalization: textCapitalization,
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            icon: const Icon(Icons.check_circle_outline, size: 22),
            label: Text(
              _selectedPaymentMethod == 'Cash on Delivery'
                  ? 'Confirm Order (M${finalTotal.toStringAsFixed(2)})'
                  : 'Pay Now (M${finalTotal.toStringAsFixed(2)})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

}