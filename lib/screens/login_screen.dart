import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; 
import 'package:junk_and_gems/providers/auth_provider.dart'; 
import 'package:junk_and_gems/screens/forgot_password_screen.dart';
import 'package:junk_and_gems/screens/signup_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';
import 'package:junk_and_gems/services/notification_service.dart';
import 'package:junk_and_gems/services/google_auth_service.dart';

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
  bool _isGoogleLoading = false;
  bool _obscurePassword = true; // Add password visibility state
  String? _errorMessage;

  // Google Sign-In Handler
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      print('Starting Google Sign-In...');
      
      final result = await GoogleAuthService.signInWithGoogle();
      
      if (result == null) {
        // User cancelled
        print('User cancelled Google Sign-In');
        return;
      }

      final userData = result['user'];
      
      // Update AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      // Then navigate
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userName: userData['name'],
              userId: userData['id'].toString(),
            ),
          ),
        );
      }
      
      print('Google Sign-In successful!');
      print('  User ID: ${authProvider.user?.id}');
      print('  User Name: ${authProvider.user?.name}');

      // Initialize notifications
      try {
        await NotificationService.scheduleDailyTip(
          hour: 10,
          minute: 0,
          enabled: true,
        );
        NotificationService.startPeriodicSync(userData['id'].toString());
        await NotificationService.syncAndShowLocalNotifications(
          userData['id'].toString(),
        );
      } catch (notifError) {
        print('Error setting up notifications: $notifError');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userId: userData['id'].toString(),
              userName: userData['name'],
            ),
          ),
        );
      }
    } catch (e) {
      print('Google Sign-In failed: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Starting login process...');

      final response = await http.post(
        Uri.parse('https://junk-and-gems-api.onrender.com/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Server returned empty response');
        }
        
        late final Map<String, dynamic> result;
        try {
          result = json.decode(response.body);
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
          print('   Response body: "${response.body}"');
          throw Exception('Invalid response from server: $jsonError');
        }
        
        print('Login response data:');
        print('   User: ${result['user']}');
        print('   Token exists: ${result['token'] != null}');
        
        final prefs = await SharedPreferences.getInstance();
        
        // Clear old auth data
        print('Clearing old auth data...');
        await prefs.remove('auth_token');
        await prefs.remove('token');
        await prefs.remove('user_data');
        await prefs.remove('userId');
        await prefs.remove('userName');
        await prefs.remove('userEmail');
        
        final token = result['token'];
        final userData = result['user'];
        
        print('Saving new user data...');
        // Store in BOTH formats
        await prefs.setString('auth_token', token);
        await prefs.setString('token', token);
        await prefs.setString('user_data', json.encode(userData));
        await prefs.setString('userId', userData['id'].toString());
        await prefs.setString('userName', userData['name']);
        await prefs.setString('userEmail', userData['email']);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGoogleUser', false); // Mark as regular user
        
        print('Stored user data:');
        print('   userId: ${userData['id']}');
        print('   userName: ${userData['name']}');
        
        // Update AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.initialize();
        
        print('AuthProvider initialized:');
        print('   User ID: ${authProvider.user?.id}');
        print('   User Name: ${authProvider.user?.name}');
        print('   Is Authenticated: ${authProvider.isAuthenticated}');

        // INITIALIZE NOTIFICATIONS AFTER LOGIN
        print('Initializing notifications...');
        try {
          await NotificationService.scheduleDailyTip(
            hour: 10,
            minute: 0,
            enabled: true,
          );
          print('Daily tips scheduled');

          NotificationService.startPeriodicSync(userData['id'].toString());
          print('Notification sync started');

          await NotificationService.syncAndShowLocalNotifications(
            userData['id'].toString(),
          );
          print('Initial notification sync completed');
        } catch (notifError) {
          print('Error setting up notifications: $notifError');
        }

        print('Login successful!');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userId: userData['id'].toString(),
                userName: userData['name'],
              ),
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login failed: $e');
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

  Widget _buildDebugButton() {
    return TextButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Auth Debug Info'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('SharedPreferences:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('user_data: ${prefs.getString('user_data')}'),
                    Text('userId: ${prefs.getString('userId')}'),
                    Text('userName: ${prefs.getString('userName')}'),
                    Text('isLoggedIn: ${prefs.getBool('isLoggedIn')}'),
                    Text('isGoogleUser: ${prefs.getBool('isGoogleUser')}'),
                    const SizedBox(height: 16),
                    const Text('AuthProvider:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Authenticated: ${authProvider.isAuthenticated}'),
                    Text('User ID: ${authProvider.user?.id}'),
                    Text('User Name: ${authProvider.user?.name}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
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
                          
                          // Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: _isGoogleLoading 
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 24,
                                      width: 24,
                                    ),
                              label: Text(
                                _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
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
                            obscureText: _obscurePassword,
                            isPassword: true,
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
    bool isPassword = false,
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
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF88844D),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
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