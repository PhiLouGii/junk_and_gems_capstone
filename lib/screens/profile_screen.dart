import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:junk_and_gems/screens/browse_materials_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'package:junk_and_gems/screens/settings_screen.dart';
import 'package:junk_and_gems/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String bioText = "";
  Map<String, String> userData = {};
  bool isLoading = true;
  bool isSavingBio = false;
  bool isSavingProfilePicture = false;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        print('❌ No auth token found in SharedPreferences');
        return null;
      }
      
      print('✅ Auth token found, length: ${token.length}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userData = {
          'id': prefs.getString('userId') ?? '',
          'name': prefs.getString('userName') ?? 'User',
          'email': prefs.getString('userEmail') ?? '',
          'username': prefs.getString('username') ?? '',
          'bio': prefs.getString('userBio') ?? '',
          'profilePicture': prefs.getString('profilePicture') ?? '',
        };
        bioText = userData['bio'] ?? '';
        _bioController.text = bioText;
      });
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfilePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, // Reduced size to prevent issues
        maxHeight: 512,
        imageQuality: 75, // Reduced quality
      );

      if (image != null) {
        setState(() {
          isSavingProfilePicture = true;
        });

        // Get auth token first
        final token = await _getAuthToken();
        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in again to update your profile picture.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            isSavingProfilePicture = false;
          });
          return;
        }

        // Read image as bytes and convert to base64
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Get user ID
        final userId = userData['id'];
        if (userId == null || userId.isEmpty) {
          throw Exception('User ID not found');
        }

        print('🖼️ Sending profile picture update for user: $userId');
        print('📸 Base64 image length: ${base64Image.length}');
        print('📸 Image size: ${bytes.length} bytes');

        // FIX: Try different base64 formats that might work with your backend
        final Map<String, dynamic> payload = {
          'image_data_base64': base64Image,
          // Alternative: try with data URL format
          // 'image_data_base64': 'data:image/jpeg;base64,$base64Image',
        };

        print('📦 Payload keys: ${payload.keys}');
        print('📦 Payload image_data_base64 type: ${payload['image_data_base64'].runtimeType}');

        // Call API to update profile picture with authentication
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3003/api/users/$userId/profile-picture'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(payload),
        );

        print('📡 Response status: ${response.statusCode}');
        print('📡 Response headers: ${response.headers}');
        print('📡 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          
          // Update local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profilePicture', responseData['profile_image_url']);
          
          // Update state
          setState(() {
            userData['profilePicture'] = responseData['profile_image_url'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please log in again.');
        } else if (response.statusCode == 500) {
          // More detailed error for 500
          final errorBody = json.decode(response.body);
          throw Exception('Server error: ${errorBody['error'] ?? 'Unknown server error'}');
        } else {
          throw Exception('Failed to update profile picture: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Error updating profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSavingProfilePicture = false;
      });
    }
  }

  Future<void> _updateBio() async {
    try {
      setState(() {
        isSavingBio = true;
      });

      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication required. Please log in again.');
      }

      final userId = userData['id'];
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      // Call API to update profile
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3003/api/users/$userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': userData['name'],
          'specialty': '',
          'bio': bioText,
          'user_type': 'user',
        }),
      );

      if (response.statusCode == 200) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userBio', bioText);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bio updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update bio: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating bio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating bio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSavingBio = false;
      });
    }
  }

  // Test the profile picture endpoint specifically
  Future<void> _testProfilePictureEndpoint() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('❌ No token for endpoint test');
        return;
      }

      final userId = userData['id'];
      print('🔍 Testing profile picture endpoint for user: $userId');
      
      // Test with a small payload
      final testPayload = {
        'image_data_base64': 'test_base64_string'
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3003/api/users/$userId/profile-picture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(testPayload),
      );

      print('🔍 Test response status: ${response.statusCode}');
      print('🔍 Test response body: ${response.body}');
    } catch (e) {
      print('❌ Endpoint test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F2E4),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF88844D),
          ),
        ),
      );
    }

    final userName = userData['name'] ?? 'User';
    final userEmail = userData['email'] ?? '';
    final username = userData['username']?.isNotEmpty == true 
        ? userData['username']!
        : (userEmail.split('@').first);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DashboardScreen(userName: userName, userId: userData['userId'] ?? '')),
          ),
        ),
        actions: [
          // Test profile picture endpoint
          IconButton(
            icon: const Icon(Icons.photo_library, color: Color(0xFF88844D)),
            onPressed: _testProfilePictureEndpoint,
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF88844D)),
            onPressed: _handleLogout,
          ),
        ],
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/logo.png", height: 64), 
            const SizedBox(width: 8),
            const Text(
              "Profile",
              style: TextStyle(
                color: Color(0xFF88844D),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(userName, username),
              const SizedBox(height: 32),
              _buildBioSection(),
              const SizedBox(height: 32),
              Divider(
                color: const Color(0xFF88844D).withOpacity(0.3),
                thickness: 1,
              ),
              const SizedBox(height: 32),
              _buildContactInformation(userEmail),
              const SizedBox(height: 32),
              _buildMyAccount(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, userName),
    );
  }

  Widget _buildProfileHeader(String userName, String username) {
    final profilePicture = userData['profilePicture'];
    
    return Column(
      children: [
        Stack(
          children: [
            // Profile Picture
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(60),
              ),
              child: profilePicture != null && profilePicture.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        profilePicture,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF88844D),
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF88844D),
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: isSavingProfilePicture ? null : _updateProfilePicture,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: isSavingProfilePicture
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF88844D),
                          ),
                        )
                      : const Icon(Icons.edit, size: 18, color: Color(0xFF88844D)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF88844D).withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Gems Counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.star, color: Colors.green, size: 18),
              SizedBox(width: 4),
              Text(
                "1250 Gems",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            TextField(
              maxLength: 120,
              maxLines: 3,
              controller: _bioController,
              onChanged: (value) {
                setState(() {
                  bioText = value;
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                filled: true,
                fillColor: Colors.white,
                hintText: "Add a little something about yourself...",
                hintStyle: TextStyle(
                  color: const Color(0xFF88844D).withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFBEC092)),
                ),
                counterText: "",
              ),
            ),
            Positioned(
              bottom: 8,
              right: 16,
              child: Text(
                "${bioText.length}/120",
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF88844D).withOpacity(0.6),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: isSavingBio ? null : _updateBio,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: isSavingBio
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF88844D),
                          ),
                        )
                      : const Icon(Icons.save, size: 16, color: Color(0xFF88844D)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInformation(String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 20),
        _buildContactItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: userEmail,
        ),
        const SizedBox(height: 20),
        _buildContactItem(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: '+266 xxxx xxxx',
        ),
      ],
    );
  }

  Widget _buildContactItem({required IconData icon, required String label, required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF88844D), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 14, color: const Color(0xFF88844D).withOpacity(0.7))),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF88844D), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 20),
        _buildAccountItem(icon: Icons.shopping_bag_outlined, label: 'My Purchases', onTap: () {}),
        const SizedBox(height: 12),
        _buildAccountItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildAccountItem({required IconData icon, required String label, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFBEC092),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF88844D), size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF88844D), fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: const Color(0xFF88844D).withOpacity(0.6),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, String userName) {
    return Container(
      height: 70,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, false, 'Home', onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen(userName: userName, userId: userData['userId'] ?? '')),
              (route) => false,
            );
          }),
          _navItem(Icons.inventory_2_outlined, false, 'Browse', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
            );
          }),
          _navItem(Icons.shopping_bag_outlined, false, 'Shop', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketplaceScreen(userName: userName, userId: userData['userId'] ?? ''),
              ),
            );
          }),
          _navItem(Icons.notifications_outlined, false, 'Alerts', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsMessagesScreen()),
            );
          }),
          _navItem(Icons.person_outline, true, 'Profile', onTap: () {
            // Already on profile screen
          }),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isSelected, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF88844D) : const Color(0xFF88844D).withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF88844D) : const Color(0xFF88844D).withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      await prefs.remove('username');
      await prefs.remove('userBio');
      await prefs.remove('profilePicture');
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }
}