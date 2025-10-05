import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:junk_and_gems/screens/browse_materials_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'package:junk_and_gems/screens/settings_screen.dart';
import 'package:junk_and_gems/screens/login_screen.dart';
import 'package:junk_and_gems/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userId;
  
  const ProfileScreen({
    super.key, 
    required this.userName,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State variables
  Map<String, dynamic> userData = {}; 
  bool isLoading = true;
  bool isSavingBio = false;
  bool isSavingProfilePicture = false;
  int userGems = 0;
  
  // Controllers and pickers
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;

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

  // ========== DATA LOADING METHODS ==========

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
        _bioController.text = userData['bio'] ?? '';
      });

      await _loadUserGems();
    } catch (e) {
      print('❌ Error loading user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserGems() async {
    try {
      print('💰 Loading user gems for user: ${widget.userId}');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3003/api/users/${widget.userId}/profile'),
      );
      
      if (response.statusCode == 200) {
        final userProfile = json.decode(response.body);
        final gems = userProfile['available_gems'] ?? 0;
        
        setState(() {
          userGems = gems is int ? gems : int.tryParse(gems.toString()) ?? 0;
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userGems', userGems);
      } else {
        print('❌ Failed to load user gems: ${response.statusCode}');
        _loadCachedGems();
      }
    } catch (e) {
      print('❌ Error loading user gems: $e');
      _loadCachedGems();
    }
  }

  Future<void> _loadCachedGems() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedGems = prefs.getInt('userGems') ?? 0;
    setState(() {
      userGems = cachedGems;
    });
  }

  // ========== AUTH METHODS ==========

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        print('❌ No auth token found');
        return null;
      }
      
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // ========== PROFILE PICTURE METHODS ==========

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        
        await _uploadProfilePicture();
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_profileImage == null) return;

    try {
      setState(() {
        isSavingProfilePicture = true;
      });

      final String? imageUrl = await UserService.uploadProfilePicture(
        int.parse(widget.userId),
        _profileImage!
      );

      if (imageUrl != null) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profilePicture', imageUrl);
        
        // Update state
        setState(() {
          userData['profilePicture'] = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSavingProfilePicture = false;
      });
    }
  }

  Widget _buildProfilePicture() {
    final profilePicture = userData['profilePicture'];
    
    return GestureDetector(
      onTap: isSavingProfilePicture ? null : _pickProfileImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBEC092), width: 3),
            ),
            child: ClipOval(
              child: _buildProfileImageContent(profilePicture),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF88844D),
                shape: BoxShape.circle,
              ),
              child: isSavingProfilePicture
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageContent(String? profilePicture) {
    if (_profileImage != null) {
      return Image.file(_profileImage!, fit: BoxFit.cover);
    } else if (profilePicture != null && profilePicture.isNotEmpty) {
      return Image.network(
        profilePicture,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildProfilePlaceholder();
        },
      );
    } else {
      return _buildProfilePlaceholder();
    }
  }

  Widget _buildProfilePlaceholder() {
    return Container(
      color: const Color(0xFFE4E5C2),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Color(0xFF88844D),
      ),
    );
  }

  // ========== BIO METHODS ==========

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

      final response = await http.put(
        Uri.parse('http://10.0.2.2:3003/api/users/$userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': userData['name'],
          'specialty': '',
          'bio': _bioController.text,
          'user_type': 'user',
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userBio', _bioController.text);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bio updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update bio: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating bio: $e');
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

  // ========== LOGOUT METHODS ==========

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Logout',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
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
      await prefs.remove('userGems');
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  // ========== UI BUILDING METHODS ==========

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).textTheme.bodyLarge?.color,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userName: userName, 
                userId: widget.userId
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
            onPressed: _handleLogout,
          ),
        ],
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/logo.png", height: 32),
            const SizedBox(width: 8),
            Text(
              "Profile",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
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
              _buildDivider(),
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
    return Column(
      children: [
        _buildProfilePicture(),
        const SizedBox(height: 16),
        Text(
          userName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildGemsCounter(),
      ],
    );
  }

  Widget _buildGemsCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.green, size: 18),
          const SizedBox(width: 4),
          Text(
            "$userGems Gems", 
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            TextField(
              maxLength: 120,
              maxLines: 3,
              controller: _bioController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                hintText: "Add a little something about yourself...",
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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
                "${_bioController.text.length}/120",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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
                    color: Theme.of(context).cardColor,
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
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        )
                      : Icon(
                          Icons.save, 
                          size: 16, 
                          color: Theme.of(context).textTheme.bodyLarge?.color
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
      thickness: 1,
    );
  }

  Widget _buildContactInformation(String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 4, 
            offset: const Offset(0, 2)
          ),
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
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14, 
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16, 
                      color: Theme.of(context).textTheme.bodyLarge?.color, 
                      fontWeight: FontWeight.w600
                    )
                  ),
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
        Text(
          'My Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 20),
        _buildAccountItem(
          icon: Icons.shopping_bag_outlined, 
          label: 'My Purchases', 
          onTap: () {}
        ),
        const SizedBox(height: 12),
        _buildAccountItem(
          icon: Icons.settings_outlined, 
          label: 'Settings', 
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        ),
      ],
    );
  }

  Widget _buildAccountItem({required IconData icon, required String label, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 4, 
            offset: const Offset(0, 2)
          ),
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
          style: TextStyle(
            fontSize: 16, 
            color: Theme.of(context).textTheme.bodyLarge?.color, 
            fontWeight: FontWeight.w600
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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
        color: Theme.of(context).cardColor,
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
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  userName: userName, 
                  userId: widget.userId
                ),
              ),
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
                builder: (context) => MarketplaceScreen(
                  userName: userName, 
                  userId: widget.userId
                ),
              ),
            );
          }),
          _navItem(Icons.notifications_outlined, false, 'Alerts', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsMessagesScreen()),
            );
          }),
          _navItem(Icons.person_outline, true, 'Profile', onTap: () {}),
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
              color: isSelected ? const Color(0xFF88844D) : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF88844D) : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}