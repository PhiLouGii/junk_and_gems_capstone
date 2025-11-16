import 'package:flutter/material.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';
import 'package:junk_and_gems/screens/refer_friends_screen.dart';
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
  bool isLoading = true;
  bool isSavingBio = false;
  bool isSavingProfilePicture = false;
  bool isEditingBio = false;
  bool isEditingContact = false;
  bool isSavingContact = false;
  
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait for auth to initialize
    if (!authProvider.isInitialized) {
      print('⏳ Waiting for auth to initialize...');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // If still not ready, wait a bit more
    int attempts = 0;
    while (!authProvider.isInitialized && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    if (!authProvider.isAuthenticated || authProvider.user == null) {
      print('❌ Not authenticated');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final user = authProvider.user!;
    
    // Set text fields from AuthProvider
    _bioController.text = user.bio ?? '';
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';

    setState(() {
      isLoading = false;
    });

    print('✅ Profile initialized: ${user.name} (${user.availableGems} gems)');
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
      print('Error picking image: $e');
      _showSnackBar('Failed to pick image', isError: true);
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_profileImage == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.id == null) return;

    try {
      setState(() {
        isSavingProfilePicture = true;
      });

      final String? imageUrl = await UserService.uploadProfilePicture(
        authProvider.user!.id!,
        _profileImage!
      );

      if (imageUrl != null) {
        // Update in AuthProvider
        await authProvider.updateProfile(profileImageUrl: imageUrl);
        
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

  Widget _buildProfilePicture(String? profilePicture) {
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

  // ========== UPDATE METHODS ==========

  Future<void> _updateBio() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.id == null) return;

    try {
      setState(() {
        isSavingBio = true;
      });

      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token');
      }

      final userId = authProvider.user!.id.toString();
      final user = authProvider.user!;

      final response = await http.put(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': user.name,
          'specialty': user.specialty ?? '',
          'bio': _bioController.text,
          'user_type': user.userType ?? 'contributor',
        }),
      );

      if (response.statusCode == 200) {
        // Update in AuthProvider
        await authProvider.updateProfile(bio: _bioController.text);
        
        setState(() {
          isEditingBio = false;
        });
        
        _showSnackBar('Bio updated successfully!');
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

  Future<void> _updateContactInfo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF88844D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF88844D), size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Update Contact Info'),
            ],
          ),
          content: const Text('Are you sure you want to update your email and phone number?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.id == null) return;

    try {
      setState(() {
        isSavingContact = true;
      });

      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token');
      }

      final userId = authProvider.user!.id.toString();
      final user = authProvider.user!;

      final response = await http.put(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': user.name,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'specialty': user.specialty ?? '',
          'bio': user.bio ?? '',
          'user_type': user.userType ?? 'contributor',
        }),
      );

      if (response.statusCode == 200) {
        // Update in AuthProvider
        await authProvider.updateProfile(
          email: _emailController.text,
          phone: _phoneController.text,
        );
        
        setState(() {
          isEditingContact = false;
        });
        
        _showSnackBar('Contact information updated!');
      } else {
        throw Exception('Failed to update: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating contact: $e');
      _showSnackBar('Error updating contact information', isError: true);
    } finally {
      setState(() {
        isSavingContact = false;
      });
    }
  }

  // ========== LOGOUT METHODS ==========

  void _handleLogout(AuthProvider authProvider) {
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
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading
        if (isLoading || !authProvider.isInitialized) {
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

        // Check authentication
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not authenticated'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = authProvider.user!;
        final userName = user.name;
        final userEmail = user.email;
        final username = user.username?.isNotEmpty == true 
            ? user.username!
            : userEmail.split('@').first;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(authProvider),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => authProvider.refresh(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildProfileHeader(user, username),
                          const SizedBox(height: 32),
                          _buildBioSection(user),
                          const SizedBox(height: 24),
                          _buildStatsRow(user),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 24),
                          _buildRecentActivity(user),
                          _buildContactInformation(user),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavBar(context, userName),
        );
      },
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
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
            onPressed: () => _handleLogout(authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user, String username) {
    return Column(
      children: [
        _buildProfilePicture(user.profileImageUrl),
        const SizedBox(height: 24),
        Text(
          user.name,
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
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF88844D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildGemsCounter(user),
      ],
    );
  }

  Widget _buildGemsCounter(User user) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  return GestureDetector(
    onTap: () async {
      // Navigate to Refer Friends screen instead of Buy Gems
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReferFriendsScreen(
            userId: user.id.toString(),
            userName: user.name,
            currentGems: user.availableGems,
          ),
        ),
      );
         // Refresh gems after returning
      await authProvider.refresh();
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
            "${user.availableGems} Gems", 
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.people_outline, color: Colors.white, size: 20),
        ],
      ),
    ),
  );
}

  Widget _buildBioSection(User user) {
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
                          _bioController.text = user.bio ?? '';
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

  Widget _buildStatsRow(User user) {
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
            value: user.totalDonations.toString(),
            label: 'Donated',
            icon: Icons.recycling,
            color: Colors.green,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            value: user.totalProducts.toString(),
            label: 'Sold',
            icon: Icons.sell,
            color: Colors.blue,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            value: user.availableGems.toString(),
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

  Widget _buildRecentActivity(User user) {
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

  Widget _buildContactInformation(User user) {
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
            value: user.email,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone ?? 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon, 
    required String label, 
    required String value,
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
                  userId: widget.userId,
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
                  userId: widget.userId,
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