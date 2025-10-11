import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:junk_and_gems/components/daily_reward_popup.dart';
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'package:junk_and_gems/screens/profile_screen.dart';
import 'package:junk_and_gems/screens/other_user_profile_screen.dart';
import 'package:junk_and_gems/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'browse_materials_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userId;
  
  const DashboardScreen({
    super.key, 
    required this.userName,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> artisans = [];
  List<dynamic> contributors = [];
  Map<String, dynamic> userImpact = {};
  bool isLoading = true;
  bool showDailyReward = false;
  Map<String, dynamic>? dailyRewardData;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkDailyReward();
  }

  Future<void> _checkDailyReward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRewardCheck = prefs.getString('lastRewardCheck_${widget.userId}');
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Only check once per day
      if (lastRewardCheck != today) {
        final rewardResponse = await UserService.claimDailyReward(widget.userId);
        
        if (rewardResponse['success'] == true) {
          setState(() {
            dailyRewardData = rewardResponse;
            showDailyReward = true;
          });
          
          // Update last check date
          await prefs.setString('lastRewardCheck_${widget.userId}', today);
        }
      }
    } catch (e) {
      print('❌ Daily reward check error: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      print('🚀 Starting to load dashboard data...');
      
      await _loadCachedData();
      
      final List<Future<dynamic>> futures = [
        UserService.getArtisans(),
        UserService.getContributors(),
        UserService.getUserImpact(widget.userId),
      ];

      final results = await Future.wait(futures);

      final artisansData = results[0] as List<dynamic>;
      final contributorsData = results[1] as List<dynamic>;
      final impactData = results[2] as Map<String, dynamic>;

      print('📊 Artisans data received: ${artisansData.length} items');
      print('📊 Contributors data received: ${contributorsData.length} items');
      print('📊 Impact data received: $impactData');

      setState(() {
        artisans = artisansData;
        contributors = contributorsData;
        userImpact = impactData;
        isLoading = false;
      });
      
      await _saveDataToCache(artisansData, contributorsData, impactData);
      
      print('✅ Dashboard data loaded successfully');
      
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cachedArtisans = prefs.getString('cachedArtisans');
      final cachedContributors = prefs.getString('cachedContributors');
      final cachedImpact = prefs.getString('cachedImpact');
      
      if (cachedArtisans != null && cachedContributors != null && cachedImpact != null) {
        print('📚 Loading cached dashboard data...');
        
        setState(() {
          artisans = List<dynamic>.from(json.decode(cachedArtisans));
          contributors = List<dynamic>.from(json.decode(cachedContributors));
          userImpact = Map<String, dynamic>.from(json.decode(cachedImpact));
        });
      }
    } catch (e) {
      print('❌ Error loading cached data: $e');
    }
  }

  Future<void> _saveDataToCache(List<dynamic> artisansData, List<dynamic> contributorsData, Map<String, dynamic> impactData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('cachedArtisans', json.encode(artisansData));
      await prefs.setString('cachedContributors', json.encode(contributorsData));
      await prefs.setString('cachedImpact', json.encode(impactData));
      
      print('💾 Dashboard data saved to cache');
    } catch (e) {
      print('❌ Error saving data to cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo with question mark button
                    _buildHeaderWithHelp(),
                    const SizedBox(height: 16),
                    
                    // Welcome Card with Ring Cycle
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    
                    // Donate & Browse Materials Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                    
                    // Three Product Items
                    _buildProductItems(),
                    const SizedBox(height: 24),
                    
                    // Artisan Highlights
                    _buildArtisanHighlights(),
                    const SizedBox(height: 24),
                    
                    // Frequent Contributors
                    _buildFrequentContributors(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Daily Reward Popup
            if (showDailyReward && dailyRewardData != null)
              DailyRewardPopup(
                gemsEarned: dailyRewardData!['gems_earned'] ?? 5,
                currentStreak: dailyRewardData!['streak'] ?? 1,
                streakBonus: dailyRewardData!['streak_bonus'] ?? 0,
                onClose: () {
                  setState(() {
                    showDailyReward = false;
                  });
                  // Refresh user impact to show updated gems
                  _loadData();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Header with Logo and Help Button
  Widget _buildHeaderWithHelp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.help_outline,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 28,
          ),
          onPressed: () {
            // TODO: Add help functionality
            print('Help button pressed');
          },
        ),
      ],
    );
  }

  // Welcome Card with Ring Cycle
  Widget _buildWelcomeCard() {
    final gemsEarned = userImpact['gems_earned']?.toString() ?? '0';
    
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.userName}!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What will you do today?',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Ring Cycle with Star Icon and Gems
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ring
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF88844D),
                        width: 8,
                      ),
                    ),
                  ),
                  
                  // Content inside ring
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: const Color(0xFF88844D),
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gemsEarned,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'Gems',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Donate & Browse Materials Buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildMaterialButton(
            'Donate Materials',
            Icons.add_circle_outline,
            onTap: () {
              // TODO: Add donate materials functionality
              print('Donate Materials pressed');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMaterialButton(
            'Browse Materials',
            Icons.search,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialButton(String text, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF2A2A2A) 
              : const Color(0xFFE4E5C2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF88844D),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Three Product Items
  Widget _buildProductItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: [
            _buildProductItem('Denim Handbag', 'assets/images/upcycled1.jpg'),
            _buildProductItem('Bottle Wall Art', 'assets/images/upcycled2.jpg'),
            _buildProductItem('Buttons Figure', 'assets/images/upcycled3.jpg'),
          ],
        ),
      ],
    );
  }

  Widget _buildProductItem(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarketplaceScreen(userName: widget.userName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF3A3A3A) 
                      : const Color(0xFFE4E5C2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.shopping_bag,
                          size: 32,
                          color: const Color(0xFF88844D),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Artisan Highlights - Horizontal Scroll with Cards
  Widget _buildArtisanHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artisan Highlights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        
        if (isLoading)
          _buildLoadingSection()
        else if (artisans.isEmpty)
          _buildEmptySection('No artisans available')
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: artisans.length,
              itemBuilder: (context, index) {
                return _buildUserCard(artisans[index], true);
              },
            ),
          ),
      ],
    );
  }

  // Frequent Contributors - Horizontal Scroll with Cards
  Widget _buildFrequentContributors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequent Contributors',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        
        if (isLoading)
          _buildLoadingSection()
        else if (contributors.isEmpty)
          _buildEmptySection('No contributors available')
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: contributors.length,
              itemBuilder: (context, index) {
                return _buildUserCard(contributors[index], false);
              },
            ),
          ),
      ],
    );
  }

  // User Card for both Artisans and Contributors
  Widget _buildUserCard(Map<String, dynamic> user, bool isArtisan) {
  final name = user['name'] ?? 'Unknown User';
  final specialty = user['specialty'] ?? (isArtisan ? 'Artisan' : 'Contributor');
  final profileImage = user['profile_image_url'];
  final userId = user['id']?.toString() ?? '0';

  print('🔄 Building user card for: $name');
  print('📸 Profile image URL: $profileImage');

  // Add cache busting
  String getImageUrlWithCacheBust(String url) {
    if (url.contains('?')) {
      return '$url&t=${DateTime.now().millisecondsSinceEpoch}';
    } else {
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    }
  }


    return GestureDetector(
    onTap: () {
      _showUserProfileModal(context, name, userId);
    },
    child: Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
         child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image with better error handling
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBEC092),
                  width: 2,
                ),
              ),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: profileImage != null && profileImage.isNotEmpty
                    ? Image.network(
                        getImageUrlWithCacheBust(profileImage),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          print('🔄 Loading image for $name...');
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Error loading image for $name: $error');
                          print('📸 Failed URL: $profileImage');
                          return _buildProfilePlaceholder();
                        },
                      )
                    : _buildProfilePlaceholder(),
              ),
            ),
            const SizedBox(height: 8),
              
              // Name
              Text(
                _getDisplayName(name),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Specialty
              Text(
                specialty,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserProfileModal(BuildContext context, String userName, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: OtherUserProfileScreen(
            userName: userName,
            userId: userId,
          ),
        );
      },
    );
  }

  Widget _buildProfilePlaceholder() {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF3A3A3A) 
          : const Color(0xFFE4E5C2),
      child: Icon(
        Icons.person,
        size: 24,
        color: const Color(0xFF88844D),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF88844D)),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  String _getDisplayName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return '${parts[0]} ${parts[1][0]}.';
    }
    return fullName;
  }

  // Bottom Nav Bar
  Widget _buildBottomNavBar(BuildContext context) {
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
          _navItem(Icons.home_filled, true, 'Home', onTap: () {}),
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
                builder: (context) => MarketplaceScreen(userName: widget.userName),
              ),
            );
          }),
          _navItem(Icons.notifications_outlined, false, 'Alerts', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsMessagesScreen()),
            );
          }),
          _navItem(Icons.person_outline, false, 'Profile', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen(userName: widget.userName, userId: widget.userId)),
            );
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
}