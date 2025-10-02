import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/screens/signup_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Save user data to shared preferences
  Future<void> _saveUserData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', user['id'].toString());
    await prefs.setString('userName', user['name']);
    await prefs.setString('userEmail', user['email']);
    await prefs.setString('username', user['username'] ?? '');
  }

  Future<void> loginUser() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse('http://10.0.2.2:3000/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if data has the expected structure
        if (data != null && data['token'] != null && data['user'] != null) {
          // Save user data to shared preferences
          await _saveUserData(data['token'], data['user']);
          
          // Navigate to Dashboard and pass the user's name
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(userName: data['user']['name']),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: Invalid response format from server")),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['error'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      print('Full error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 200,
                        height: 200,
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
                          'Hi Again!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Log back into your account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(
                          controller: emailController,
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F2E4),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF88844D)),
                                  ),
                                  child: const Icon(Icons.check, size: 14, color: Color(0xFF88844D)),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember Me',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF88844D),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : loginUser,
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
                                    'Log In',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF88844D),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
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
  }) =>
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2E4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
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
          child: Container(width: 300, height: 300, decoration: BoxDecoration(color: blobColor.withOpacity(0.3), borderRadius: BorderRadius.circular(150))),
        ),
        Positioned(
          top: -50,
          right: -80,
          child: Container(width: 200, height: 200, decoration: BoxDecoration(color: blobColor.withOpacity(0.2), borderRadius: BorderRadius.circular(100))),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(width: 150, height: 150, decoration: BoxDecoration(color: blobColor.withOpacity(0.4), borderRadius: BorderRadius.circular(75))),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: Container(width: 180, height: 180, decoration: BoxDecoration(color: blobColor.withOpacity(0.25), borderRadius: BorderRadius.circular(90))),
        ),
        Positioned(
          left: -30,
          top: MediaQuery.of(context).size.height * 0.4,
          child: Container(width: 100, height: 100, decoration: BoxDecoration(color: blobColor.withOpacity(0.3), borderRadius: BorderRadius.circular(50))),
        ),
      ],
    );
  }
}
