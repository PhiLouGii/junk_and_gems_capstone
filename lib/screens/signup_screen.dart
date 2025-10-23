import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool includePhoneNumber = false;
  
  static const String lesothoCountryCode = '+266';

  @override
  void initState() {
    super.initState();
    // Add listener to maintain country code
    phoneController.addListener(_handlePhoneNumberChange);
  }

  @override
  void dispose() {
    phoneController.removeListener(_handlePhoneNumberChange);
    super.dispose();
  }

  void _handlePhoneNumberChange() {
    final text = phoneController.text;
    // Ensure country code is always present
    if (includePhoneNumber && !text.startsWith(lesothoCountryCode)) {
      if (text.isEmpty || text.startsWith('+')) {
        phoneController.value = TextEditingValue(
          text: '$lesothoCountryCode ',
          selection: TextSelection.collapsed(offset: lesothoCountryCode.length + 1),
        );
      }
    }
  }

  // Phone number validation
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    // Remove spaces for validation
    final cleanNumber = value.replaceAll(' ', '');
    
    // Should start with +266 and have 8 more digits (Lesotho format)
    if (!cleanNumber.startsWith(lesothoCountryCode)) {
      return 'Phone number must start with +266';
    }
    
    // Remove country code and check remaining digits
    final numberWithoutCode = cleanNumber.substring(4);
    if (numberWithoutCode.length != 8) {
      return 'Please enter 8 digits after +266';
    }
    
    return null;
  }

  Future<void> signUpUser() async {
    // Validate passwords match
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate phone number if provided
    if (includePhoneNumber && phoneController.text.isNotEmpty) {
      final phoneError = validatePhoneNumber(phoneController.text);
      if (phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(phoneError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('https://junk-and-gems-api.onrender.com/signup');
      
      final Map<String, dynamic> requestBody = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      };

      // Add phone number only if user opted in and provided it
      if (includePhoneNumber && phoneController.text.trim().isNotEmpty) {
        requestBody['phone_number'] = phoneController.text.trim();
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome ${data['user']['name']}! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to login
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${data['error']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      body: Stack(
        children: [
          _buildBackgroundBlobs(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Junk & Gems',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join the community',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 32),
                        
                        // Name field
                        _buildTextField(
                            controller: nameController,
                            hintText: 'Full Name',
                            icon: Icons.person_outline),
                        const SizedBox(height: 20),
                        
                        // Email field
                        _buildTextField(
                            controller: emailController,
                            hintText: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 20),
                        
                        // Phone number toggle
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F2E4).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                color: const Color(0xFF88844D),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add phone number (optional)',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Switch(
                                value: includePhoneNumber,
                                onChanged: (value) {
                                  setState(() {
                                    includePhoneNumber = value;
                                    if (!value) {
                                      phoneController.clear();
                                    }
                                  });
                                },
                                activeColor: const Color(0xFF88844D),
                              ),
                            ],
                          ),
                        ),
                        
                        // Phone number field (conditional)
                        if (includePhoneNumber) ...[
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: phoneController,
                            hintText: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d+\s\-()]')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Used for order updates and delivery coordination',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // Password field
                        _buildTextField(
                            controller: passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true),
                        const SizedBox(height: 20),
                        
                        // Confirm password field
                        _buildTextField(
                            controller: confirmPasswordController,
                            hintText: 'Confirm Password',
                            icon: Icons.lock_outline,
                            obscureText: true),
                        const SizedBox(height: 30),
                        
                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : signUpUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF88844D),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Have an account? ",
                                style: TextStyle(color: Colors.black54)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                    color: Color(0xFF88844D),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2E4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: Icon(icon, color: const Color(0xFF88844D)),
          ),
        ),
      );

  Widget _buildBackgroundBlobs(BuildContext context) {
    const Color blobColor = Color(0xFFA3A87F);
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
                color: blobColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(150)),
          ),
        ),
        Positioned(
          top: -50,
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                color: blobColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100)),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                color: const Color(0xFFF7F2E4).withOpacity(0.4),
                borderRadius: BorderRadius.circular(75)),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
                color: blobColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(90)),
          ),
        ),
        Positioned(
          left: -30,
          top: MediaQuery.of(context).size.height * 0.4,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: const Color(0xFFF7F2E4).withOpacity(0.3),
                borderRadius: BorderRadius.circular(50)),
          ),
        ),
      ],
    );
  }
}