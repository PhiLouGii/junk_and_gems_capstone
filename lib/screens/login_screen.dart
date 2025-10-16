import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/screens/forgot_password_screen.dart';
import 'package:junk_and_gems/screens/signup_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // 🔧 FIXED: Clear all old user data before login
  Future<void> _clearOldUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    print('🗑️ Clearing old user data...');
    
    // Remove all user-specific data
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('user_id');
    await prefs.remove('userName');
    await prefs.remove('user_name');
    await prefs.remove('userEmail');
    await prefs.remove('user_email');
    await prefs.remove('username');
    await prefs.remove('userBio');
    await prefs.remove('user_bio');
    await prefs.remove('profilePicture');
    await prefs.remove('profile_picture');
    await prefs.remove('userGems');
    await prefs.remove('specialty');
    await prefs.remove('user_type');
    
    print('✅ Old user data cleared');
  }

  // 🔧 FIXED: Handles login with proper data clearing
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔐 Starting login process...');
      
      // STEP 1: Clear old user data first
      await _clearOldUserData();

      // STEP 2: Make login API call
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3003/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      print('📥 Login response status: ${response.statusCode}');
      print('📥 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        // STEP 3: Store new user data
        final prefs = await SharedPreferences.getInstance();
        
        final userId = result['user']['id'].toString();
        final userName = result['user']['name'];
        final userEmail = result['user']['email'];
        final username = result['user']['username'] ?? userEmail.split('@')[0];
        final token = result['token'];
        
        print('💾 Storing new user data:');
        print('  - ID: $userId');
        print('  - Name: $userName');
        print('  - Email: $userEmail');
        print('  - Username: $username');
        
        // Store all user data with both key formats for compatibility
        await prefs.setString('token', token);
        await prefs.setString('userId', userId);
        await prefs.setString('user_id', userId);
        await prefs.setString('userName', userName);
        await prefs.setString('user_name', userName);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('user_email', userEmail);
        await prefs.setString('username', username);
        
        // STEP 4: Fetch fresh profile data from server
        print('🌐 Fetching fresh profile data...');
        try {
          final profileResponse = await http.get(
            Uri.parse('http://10.0.2.2:3003/api/users/$userId/profile'),
          );
          
          if (profileResponse.statusCode == 200) {
            final profileData = json.decode(profileResponse.body);
            
            // Store profile-specific data
            await prefs.setString('userBio', profileData['bio'] ?? '');
            await prefs.setString('user_bio', profileData['bio'] ?? '');
            await prefs.setString('profilePicture', profileData['profile_image_url'] ?? '');
            await prefs.setString('profile_picture', profileData['profile_image_url'] ?? '');
            await prefs.setInt('userGems', profileData['available_gems'] ?? 0);
            await prefs.setString('specialty', profileData['specialty'] ?? '');
            await prefs.setString('user_type', profileData['user_type'] ?? 'contributor');
            
            print('✅ Profile data loaded:');
            print('  - Bio: ${profileData['bio'] ?? '(empty)'}');
            print('  - Profile Picture: ${profileData['profile_image_url'] ?? '(none)'}');
            print('  - Gems: ${profileData['available_gems'] ?? 0}');
          } else {
            print('⚠️ Could not fetch profile data: ${profileResponse.statusCode}');
          }
        } catch (profileError) {
          print('⚠️ Profile fetch error (non-critical): $profileError');
        }

        print('✅ Login successful!');

        // STEP 5: Navigate to dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userId: userId,
                userName: userName,
              ),
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login failed: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Debug button to test stored authentication data
  Widget _buildDebugButton() {
    return TextButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        
        print('🔍 DEBUG AUTH STATUS:');
        print('All keys: ${prefs.getKeys()}');
        print('Token: ${prefs.getString('token')?.substring(0, 20)}...');
        print('User ID: ${prefs.getString('userId')}');
        print('User Name: ${prefs.getString('userName')}');
        print('User Email: ${prefs.getString('userEmail')}');
        print('User Bio: ${prefs.getString('userBio')}');
        print('Profile Picture: ${prefs.getString('profilePicture')}');
        print('User Gems: ${prefs.getInt('userGems')}');
        
        final hasToken = prefs.getString('token') != null;
        final hasUserId = prefs.getString('userId') != null;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged in: ${hasToken && hasUserId}\nCheck console for details'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: const Text(
        'Debug Auth Status',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
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
              child: Form(
                key: _formKey,
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
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
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
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF88844D),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Log In',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 20),
                          _buildDebugButton(),
                          const SizedBox(height: 20),
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
    String? Function(String?)? validator,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2E4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
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