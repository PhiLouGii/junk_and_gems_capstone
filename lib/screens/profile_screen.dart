import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/buy_gems_screen.dart';
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
import 'package:junk_and_gems/utils/app_localizations.dart';

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
  Map<String, dynamic> userData = {}; 
  bool isLoading = true;
  bool isSavingBio = false;
  bool isSavingProfilePicture = false;
  bool isEditingBio = false;
  int userGems = 0;
  
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
      
      print('📦 CHECKING SHARED PREFERENCES');
      print('All keys: ${prefs.getKeys()}');
      
      final currentUserId = widget.userId;
      print('🎯 Current logged-in user ID: $currentUserId');
      
      final cachedUserId = prefs.getString('userId') ?? prefs.getString('user_id');
      print('💾 Cached user ID: $cachedUserId');
      
      if (cachedUserId != currentUserId) {
        print('⚠️ User mismatch! Clearing old cache and fetching fresh data...');
        await _clearUserCache();
      }
      
      print('🌐 Fetching fresh profile data from server...');
      try {
        final response = await http.get(
          Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$currentUserId/profile'),
        );
        
        if (response.statusCode == 200) {
          final serverData = json.decode(response.body);
          print('✅ Server data received: ${serverData.toString()}');
          
          await prefs.setString('userId', currentUserId);
          await prefs.setString('user_id', currentUserId);
          await prefs.setString('userName', serverData['name'] ?? widget.userName);
          await prefs.setString('user_name', serverData['name'] ?? widget.userName);
          await prefs.setString('userEmail', serverData['email'] ?? '');
          await prefs.setString('user_email', serverData['email'] ?? '');
          await prefs.setString('username', serverData['username'] ?? '');
          await prefs.setString('userBio', serverData['bio'] ?? '');
          await prefs.setString('user_bio', serverData['bio'] ?? '');
          await prefs.setString('profilePicture', serverData['profile_image_url'] ?? '');
          await prefs.setString('profile_picture', serverData['profile_image_url'] ?? '');
          
          setState(() {
            userData = {
              'id': currentUserId,
              'name': serverData['name'] ?? widget.userName,
              'email': serverData['email'] ?? '',
              'username': serverData['username'] ?? '',
              'bio': serverData['bio'] ?? '',
              'profilePicture': serverData['profile_image_url'] ?? '',
              'specialty': serverData['specialty'] ?? '',
              'user_type': serverData['user_type'] ?? 'contributor',
            };
            _bioController.text = userData['bio'] ?? '';
          });
          
          print('✅ Profile data loaded from server for user: ${userData['name']}');
        } else {
          print('⚠️ Server returned ${response.statusCode}, using cached/widget data');
          await _loadFromCacheOrWidget(prefs, currentUserId);
        }
      } catch (serverError) {
        print('⚠️ Server fetch failed: $serverError, using cached/widget data');
        await _loadFromCacheOrWidget(prefs, currentUserId);
      }
      
      await _loadUserGems();
    } catch (e) {
      print('❌ Error loading user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFromCacheOrWidget(SharedPreferences prefs, String currentUserId) async {
    setState(() {
      userData = {
        'id': currentUserId,
        'name': prefs.getString('userName') ?? 
                prefs.getString('user_name') ?? 
                widget.userName,
        'email': prefs.getString('userEmail') ?? 
                 prefs.getString('user_email') ?? 
                 '',
        'username': prefs.getString('username') ?? '',
        'bio': prefs.getString('userBio') ?? 
               prefs.getString('user_bio') ?? 
               '',
        'profilePicture': prefs.getString('profilePicture') ?? 
                         prefs.getString('profile_picture') ?? 
                         '',
      };
      _bioController.text = userData['bio'] ?? '';
    });
  }

  Future<void> _clearUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userBio');
    await prefs.remove('user_bio');
    await prefs.remove('profilePicture');
    await prefs.remove('profile_picture');
    await prefs.remove('userGems');
    print('✅ Old user cache cleared');
  }

  Future<void> _loadUserGems() async {
    try {
      final userId = userData['id'] ?? widget.userId;
      print('💰 Loading user gems for user: $userId');
      
      final response = await http.get(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$userId/profile'),
      );
      
      if (response.statusCode == 200) {
        final userProfile = json.decode(response.body);
        final gems = userProfile['available_gems'] ?? 0;
        
        setState(() {
          userGems = gems is int ? gems : int.tryParse(gems.toString()) ?? 0;
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userGems', userGems);
        
        print('✅ Loaded gems: $userGems for user $userId');
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
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        
        await _uploadProfilePicture();
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      _showSnackBar('Failed to pick image', isError: true);
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profilePicture', imageUrl);
        
        setState(() {
          userData['profilePicture'] = imageUrl;
        });

        _showSnackBar('Profile picture updated! ✨');
      }
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      _showSnackBar('Failed to upload picture', isError: true);
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
          Hero(
            tag: 'profile_picture',
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF88844D).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                ),
                child: ClipOval(
                  child: _buildProfileImageContent(profilePicture),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF88844D).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSavingProfilePicture
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.camera_alt, size: 20, color: Colors.white),
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
              color: const Color(0xFF88844D),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFBEC092).withOpacity(0.3),
            const Color(0xFF88844D).withOpacity(0.2),
          ],
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
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

      String userType = 'contributor';
      try {
        final profileResponse = await http.get(
          Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$userId/profile'),
        );
        if (profileResponse.statusCode == 200) {
          final profileData = json.decode(profileResponse.body);
          userType = profileData['user_type'] ?? 'contributor';
          print('✅ Current user_type: $userType');
        }
      } catch (e) {
        print('⚠️ Could not fetch current user_type, using default: $e');
      }

      final response = await http.put(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': userData['name'],
          'specialty': userData['specialty'] ?? '',
          'bio': _bioController.text,
          'user_type': userType,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userBio', _bioController.text);
        
        setState(() {
          userData['bio'] = _bioController.text;
          isEditingBio = false;
        });
        
        _showSnackBar('Bio updated successfully! ✨');
      } else {
        throw Exception('Failed to update bio: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating bio: $e');
      _showSnackBar('Error updating bio', isError: true);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
      await prefs.clear();
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF88844D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ========== UI BUILDING METHODS ==========

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFBEC092).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  color: Color(0xFF88844D),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isWideScreen = constraints.maxWidth > 700;
                  
                  if (isWideScreen) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 400,
                            child: Column(
                              children: [
                                _buildProfileHeader(userName, username),
                                const SizedBox(height: 32),
                                _buildBioSection(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildContactInformation(userEmail),
                                const SizedBox(height: 24),
                                _buildMyAccount(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildProfileHeader(userName, username),
                          const SizedBox(height: 32),
                          _buildBioSection(),
                          const SizedBox(height: 24),
                          _buildStatsRow(),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 24),
                          _buildRecentActivity(),
                          _buildContactInformation(userEmail),
                          const SizedBox(height: 24),
                          _buildMyAccount(),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, userName),
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
                Image.asset('assets/images/logo.png', width: 40, height: 40),
                const SizedBox(width: 12),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String userName, String username) {
    return Column(
      children: [
        _buildProfilePicture(),
        const SizedBox(height: 24),
        Text(
          userName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFBEC092).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFBEC092).withOpacity(0.5),
            ),
          ),
          child: Text(
            '@$username',
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF88844D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildGemsCounter(),
      ],
    );
  }

  Widget _buildGemsCounter() {
  return GestureDetector(
    onTap: () async {
      // Navigate to Buy Gems screen
      final newBalance = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuyGemsScreen(
            userId: widget.userId,
            currentGems: userGems,
          ),
        ),
      );
      
      // Update gems if purchase was made
      if (newBalance != null) {
        setState(() {
          userGems = newBalance;
        });
        await _loadUserGems(); // Refresh from server
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF88844D), Color(0xFFBEC092)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            "$userGems Gems", 
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
        ],
      ),
    ),
  );
}

  Widget _buildBioSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Icons.person_outline,
                      color: Color(0xFF88844D),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              if (!isEditingBio)
                IconButton(
                  onPressed: () {
                    setState(() {
                      isEditingBio = true;
                    });
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF88844D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFF88844D),
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isEditingBio 
                  ? Theme.of(context).scaffoldBackgroundColor 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEditingBio 
                    ? const Color(0xFFBEC092) 
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: TextField(
              maxLength: 120,
              maxLines: 4,
              controller: _bioController,
              enabled: isEditingBio,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 15,
                height: 1.5,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                hintText: "Tell us a bit about yourself...",
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
                counterText: "",
              ),
            ),
          ),
          if (isEditingBio) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_bioController.text.length}/120",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _bioController.text = userData['bio'] ?? '';
                          isEditingBio = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isSavingBio ? null : _updateBio,
                      icon: isSavingBio
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save, size: 18),
                      label: Text(isSavingBio ? 'Saving...' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF88844D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
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
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          value: userData['total_donations']?.toString() ?? '0',
          label: 'Donated',
          icon: Icons.recycling,
          color: Colors.green,
        ),
        _buildVerticalDivider(),
        _buildStatItem(
          value: userData['total_products']?.toString() ?? '0',
          label: 'Sold',
          icon: Icons.sell,
          color: Colors.blue,
        ),
        _buildVerticalDivider(),
        _buildStatItem(
          value: userGems.toString(),
          label: 'Gems',
          icon: Icons.diamond,
          color: const Color(0xFF88844D),
        ),
      ],
    ),
  );
}

Widget _buildStatItem({
  required String value,
  required String label,
  required IconData icon,
  required Color color,
}) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 12),
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _buildVerticalDivider() {
  return Container(
    height: 60,
    width: 1,
    color: Theme.of(context).dividerColor.withOpacity(0.2),
  );
}

Widget _buildActionButtons() {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isEditingBio = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF88844D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFBEC092),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.settings_outlined),
          color: const Color(0xFF88844D),
          iconSize: 24,
        ),
      ),
      const SizedBox(width: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFBEC092),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.visibility_outlined),
          color: const Color(0xFF88844D),
          iconSize: 24,
        ),
      ),
    ],
  );
}

Widget _buildRecentActivity() {
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
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadRecentActivity(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: Color(0xFF88844D),
                  ),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyActivity();
            }

            return Column(
              children: snapshot.data!.map((activity) {
                return _buildActivityItem(
                  title: activity['title'] ?? '',
                  subtitle: activity['subtitle'] ?? '',
                  icon: activity['icon'] ?? Icons.circle,
                  color: activity['color'] ?? Colors.grey,
                  time: activity['time'] ?? '',
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );
}

Future<List<Map<String, dynamic>>> _loadRecentActivity() async {
  try {
    final userId = widget.userId;
    final activities = <Map<String, dynamic>>[];

    // Fetch user's donations
    final donationsResponse = await http.get(
      Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$userId/donations'),
    );

    if (donationsResponse.statusCode == 200) {
      final donations = json.decode(donationsResponse.body) as List;
      for (var donation in donations.take(2)) {
        activities.add({
          'title': 'New donation listed',
          'subtitle': donation['title'] ?? 'Material donation',
          'icon': Icons.recycling,
          'color': Colors.green,
          'time': _formatTimeAgo(donation['created_at']),
        });
      }
    }

    // Fetch user's products
    final productsResponse = await http.get(
      Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$userId/products'),
    );

    if (productsResponse.statusCode == 200) {
      final products = json.decode(productsResponse.body) as List;
      for (var product in products.take(2)) {
        activities.add({
          'title': 'New product for sale',
          'subtitle': product['title'] ?? 'Upcycled product',
          'icon': Icons.shopping_bag,
          'color': Colors.orange,
          'time': _formatTimeAgo(product['created_at']),
        });
      }
    }

    // Sort by time (most recent first)
    activities.sort((a, b) => b['time'].compareTo(a['time']));

    return activities.take(3).toList();
  } catch (e) {
    print('❌ Error loading recent activity: $e');
    return [];
  }
}

String _formatTimeAgo(String? dateString) {
  if (dateString == null) return 'Recently';
  
  try {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  } catch (e) {
    return 'Recently';
  }
}

Widget _buildActivityItem({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required String time,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFBEC092).withOpacity(0.2),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildEmptyActivity() {
  return Container(
    padding: const EdgeInsets.all(32),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFBEC092).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inbox_outlined,
            size: 40,
            color: const Color(0xFF88844D).withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No recent activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your donations and sales will appear here',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

  Widget _buildContactInformation(String userEmail) {
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
                  Icons.contacts_outlined,
                  color: Color(0xFF88844D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: userEmail,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+266 xxxx xxxx',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon, 
    required String label, 
    required String value
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBEC092).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFBEC092).withOpacity(0.3),
                  const Color(0xFF88844D).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF88844D), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12, 
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15, 
                    color: Theme.of(context).textTheme.bodyLarge?.color, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAccount() {
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
                  Icons.account_circle_outlined,
                  color: Color(0xFF88844D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'My Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildAccountItem({
    required IconData icon, 
    required String label, 
    VoidCallback? onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFBEC092).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFBEC092).withOpacity(0.3),
                    const Color(0xFF88844D).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF88844D), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15, 
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
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
          _navItem(Icons.person, true, 'Profile', onTap: () {}),
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
              color: isSelected ? const Color(0xFF88844D) : const Color(0xFF88844D).withOpacity(0.5),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? const Color(0xFF88844D) : const Color(0xFF88844D).withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}