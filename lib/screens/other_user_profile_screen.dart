import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/services/user_service.dart';
import 'package:junk_and_gems/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/utils/app_localizations.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const OtherUserProfileScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  Map<String, dynamic>? userProfile;
  List<dynamic> donations = [];
  List<dynamic> products = [];
  bool isLoading = true;
  String? _currentUserId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUserData();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getString('userId');
        _token = prefs.getString('token');
      });
      print('✅ Current User ID loaded: $_currentUserId');
    } catch (e) {
      print('❌ Error loading current user: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      print('🔄 Loading user data for user ID: ${widget.userId}');
      
      final profileData = await UserService.getOtherUserProfile(widget.userId);
      final donationsData = await UserService.getDonationsByUserId(widget.userId);
      final productsData = await UserService.getProductsByUserId(widget.userId);

      print('📊 Profile data: $profileData');
      print('📦 Donations data: $donationsData');
      print('🛍️ Products data: $productsData');

      setState(() {
        userProfile = profileData;
        donations = donationsData;
        products = productsData;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper method to extract the first image URL from various possible field formats
  String? _extractImageUrl(Map<String, dynamic> item) {
    // Try different possible field names
    final possibleFields = [
      'image_url',
      'image_urls', 
      'imageUrl',
      'imageUrls',
      'image_data_base64',
      'images',
      'product_image_url',
    ];

    for (var field in possibleFields) {
      final value = item[field];
      
      if (value == null) continue;
      
      // Handle string (single image URL)
      if (value is String && value.isNotEmpty) {
        print('✅ Found image in field "$field": $value');
        return value;
      }
      
      // Handle list of URLs
      if (value is List && value.isNotEmpty) {
        final firstItem = value[0];
        if (firstItem is String && firstItem.isNotEmpty) {
          print('✅ Found image list in field "$field": $firstItem');
          return firstItem;
        }
      }
    }
    
    print('⚠️ No image found in item: ${item.keys.toList()}');
    return null;
  }

  Future<void> _startConversationAndNavigate(String initialMessage) async {
    if (_currentUserId == null || _token == null) {
      _showErrorSnackbar('Please log in to send messages');
      return;
    }

    if (_currentUserId == widget.userId) {
      _showErrorSnackbar('You cannot message yourself');
      return;
    }

    try {
      print('🚀 Starting conversation...');
      print('Current User ID: $_currentUserId');
      print('Other User ID: ${widget.userId}');
      print('Initial Message: $initialMessage');

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: const Color(0xFF88844D)),
                const SizedBox(height: 16),
                Text(
                  'Starting conversation...',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final response = await http.post(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/conversations/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'currentUserId': _currentUserId,
          'otherUserId': widget.userId,
          'initialMessage': initialMessage,
        }),
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final conversationId = data['id'].toString();

        print('✅ Conversation created/found: $conversationId');

        // Navigate to chat screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userName: widget.userName,
                otherUserId: widget.userId,
                currentUserId: _currentUserId!,
                conversationId: conversationId,
              ),
            ),
          );
        }
      } else {
        print('❌ Failed to start conversation: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        _showErrorSnackbar('Failed to start conversation. Please try again.');
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (mounted) Navigator.pop(context);
      
      print('❌ Error starting conversation: $e');
      _showErrorSnackbar('Network error. Please check your connection.');
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showImageFullScreen(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading 
            ? _buildLoadingState()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(context),
                    const SizedBox(height: 24),
                    _buildUserStats(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 32),
                    _buildRecentDonations(context),
                    const SizedBox(height: 32),
                    _buildUpcycledProducts(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: const Color(0xFF88844D)),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final userType = userProfile?['user_type'] ?? 'member';
    final specialty = userProfile?['specialty'] ?? '';
    final bio = userProfile?['bio'] ?? '';
    final profileImage = userProfile?['profile_image_url'];

    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFBEC092),
                width: 3,
              ),
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF3A3A3A) 
                  : const Color(0xFFE4E5C2),
            ),
            child: profileImage != null && profileImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      profileImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 50,
                          color: const Color(0xFF88844D),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
                    color: const Color(0xFF88844D),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.userName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          if (userType.isNotEmpty || specialty.isNotEmpty) ...[
            Text(
              _getUserTypeDisplay(userType, specialty),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (bio.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserStats(BuildContext context) {
    final totalDonations = userProfile?['total_donations'] ?? 0;
    final totalProducts = userProfile?['total_products'] ?? 0;
    final donationCount = userProfile?['donation_count'] ?? 0;
    final availableGems = userProfile?['available_gems'] ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCell(totalDonations.toString(), 'Donations'),
          _buildStatCell(totalProducts.toString(), 'Products'),
          _buildStatCell(donationCount.toString(), 'Total Donated'),
          _buildStatCell(availableGems.toString(), 'Gems'),
        ],
      ),
    );
  }

  Widget _buildStatCell(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _showMessageDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF88844D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: 20),
                SizedBox(width: 8),
                Text(
                  'Message User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 60,
          child: ElevatedButton(
            onPressed: () {
              _showReportDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF3A3A3A) 
                  : const Color(0xFFE4E5C2),
              foregroundColor: const Color(0xFF88844D),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Icon(Icons.flag, size: 20),
          ),
        ),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Report ${widget.userName}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please select a reason for reporting:',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              _buildReportOption('Inappropriate content', context),
              _buildReportOption('Harassment or bullying', context),
              _buildReportOption('Spam or misleading information', context),
              _buildReportOption('Impersonation', context),
              _buildReportOption('Other', context),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showReportSubmittedSnackbar(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Report'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            size: 20,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportSubmittedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF88844D),
        content: Text(
          'Report submitted for ${widget.userName}',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRecentDonations(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Recent Donations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          if (donations.isEmpty)
            _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No donations yet!',
              subtitle: 'Donations will appear here',
            )
          else
            _buildDonationsList(),
        ],
      ),
    );
  }

  Widget _buildDonationsList() {
    return Column(
      children: donations.take(5).map((donation) => _buildDonationCard(donation)).toList(),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    print('🎁 Donation data: $donation');
    final imageUrl = _extractImageUrl(donation);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (imageUrl != null) {
                  _showImageFullScreen(imageUrl);
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF3A3A3A) 
                      : const Color(0xFFE4E5C2),
                ),
                child: _buildDonationImage(imageUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation['title']?.toString() ?? 'Untitled Donation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    donation['description']?.toString() ?? 'No description',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${donation['quantity']?.toString() ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  if (donation['category'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${donation['category']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading donation image: $error');
            return _buildDonationPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF88844D),
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    }
    
    return _buildDonationPlaceholder();
  }

  Widget _buildDonationPlaceholder() {
    return Center(
      child: Icon(
        Icons.recycling,
        size: 32,
        color: const Color(0xFF88844D).withOpacity(0.5),
      ),
    );
  }

  Widget _buildUpcycledProducts(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Upcycled Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          if (products.isEmpty)
            _buildEmptyState(
              icon: Icons.recycling_outlined,
              title: 'No products listed yet.',
              subtitle: 'Creations will appear here',
            )
          else
            _buildProductsGrid(),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    print('🛍️ Product data: $product');
    final imageUrl = _extractImageUrl(product);
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasImage) {
          _showImageFullScreen(imageUrl);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF3A3A3A) 
                      : const Color(0xFFE4E5C2),
                ),
                child: hasImage
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Error loading product image: $error');
                                return _buildProductPlaceholder();
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF88844D),
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildProductPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title']?.toString() ?? 'Untitled Product',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product['price'] != null)
                    Text(
                      'M ${product['price']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF88844D),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPlaceholder() {
    return Center(
      child: Icon(
        Icons.shopping_bag,
        size: 40,
        color: const Color(0xFF88844D).withOpacity(0.5),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getUserTypeDisplay(String userType, String specialty) {
    if (userType == 'artisan') {
      return specialty.isNotEmpty ? '$specialty Artisan' : 'Artisan';
    } else if (userType == 'contributor') {
      return specialty.isNotEmpty ? '$specialty Contributor' : 'Contributor';
    } else if (userType == 'both') {
      return specialty.isNotEmpty ? '$specialty Creator' : 'Community Member';
    }
    return 'Active Member';
  }

  void _showMessageDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Message ${widget.userName}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: messageController,
            maxLines: 5,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type your message here...',
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF88844D),
                ),
              ),
            ),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                messageController.dispose();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final message = messageController.text.trim();
                if (message.isEmpty) {
                  _showErrorSnackbar('Please enter a message');
                  return;
                }
                
                Navigator.pop(context);
                _startConversationAndNavigate(message);
                messageController.dispose();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}