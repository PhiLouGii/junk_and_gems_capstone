import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'package:junk_and_gems/screens/profile_screen.dart';
import 'package:junk_and_gems/screens/other_user_profile_screen.dart';
import 'package:junk_and_gems/utils/session_manager.dart';
import 'package:junk_and_gems/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  try {
    print('🚀 Starting to load dashboard data...');
    
     final List<Future<dynamic>> futures = [
      UserService.getArtisans(),
      UserService.getContributors(),
      UserService.getUserImpact(widget.userId),
    ];

    final results = await Future.wait(futures);

    // Now cast the results to their proper types
    final artisansData = results[0] as List<dynamic>;
    final contributorsData = results[1] as List<dynamic>;
    final impactData = results[2] as Map<String, dynamic>;

    print('📊 Artisans data received: ${artisansData.length} items');
    print('📊 Contributors data received: ${contributorsData.length} items');
    print('📊 Impact data received: $impactData');
    
    if (artisansData.isNotEmpty) {
      print('👨‍🎨 First artisan: ${artisansData[0]}');
    } else {
      print('❌ No artisans found!');
    }
    
    if (contributorsData.isNotEmpty) {
      print('👥 First contributor: ${contributorsData[0]}');
    } else {
      print('❌ No contributors found!');
    }

    setState(() {
      artisans = artisansData;
      contributors = contributorsData;
      userImpact = impactData;
      isLoading = false;
    });
    
    print('✅ Dashboard data loaded successfully');
    
  } catch (e) {
    print('❌ Error loading dashboard data: $e');
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(height: 16),
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildImpactSection(), // UPDATED: Now uses real data
                const SizedBox(height: 24),
                _buildArtisanCarousel(),
                const SizedBox(height: 24),
                _buildContributorCarousel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Logo
  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        width: 150,
        height: 150,
        fit: BoxFit.contain,
      ),
    );
  }

  // Welcome Card
  Widget _buildWelcomeCard() {
    return Center(
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${widget.userName}!',
                style: TextStyle(
                  fontSize: 24,
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
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildSmallActionCard('Donate Materials', icon: Icons.recycling),
            _buildSmallActionCard('Browse Materials', icon: Icons.search, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
              );
            }),
            _buildUpcycledCard('Denim Handbag', 'assets/images/upcycled1.jpg'),
            _buildUpcycledCard('Beer Bottle Wall Art', 'assets/images/upcycled2.jpg'),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallActionCard(String title, {IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) 
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF3A3A3A) 
                      : const Color(0xFFBEC092),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF88844D)),
              ),
            const SizedBox(height: 8),
            Text(
              title,
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

  // Upcycled Item Card with gradient and Shop Now button
  Widget _buildUpcycledCard(String title, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Fallback if image doesn't exist
            Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFBEC092),
                  child: const Icon(Icons.recycling, size: 40, color: Color(0xFF88844D)),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to marketplace
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF88844D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Shop Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Impact Section
  Widget _buildImpactSection() {
    // Use real data if available, otherwise fallback to demo data
    final piecesDonated = userImpact['pieces_donated']?.toString() ?? '0';
    final upcycledItems = userImpact['upcycled_items']?.toString() ?? '0';
    final gemsEarned = userImpact['gems_earned']?.toString() ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Impact',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
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
              _buildImpactCell(piecesDonated, 'pieces donated'),
              _buildImpactCell(upcycledItems, 'upcycled items'),
              _buildImpactCell(gemsEarned, 'gems earned'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactCell(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Artisan Carousel with Real Data
  Widget _buildArtisanCarousel() {
    if (isLoading) {
      return _buildLoadingCarousel("Artisan Highlights");
    }

    if (artisans.isEmpty) {
      return _buildEmptyCarousel("Artisan Highlights", "No artisans yet");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Artisan Highlights",
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        cs.CarouselSlider(
          items: artisans.map((artisan) => _buildUserCard(artisan, true)).toList(),
          options: cs.CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            viewportFraction: 0.45,
            enableInfiniteScroll: true,
          ),
        ),
      ],
    );
  }

  // Contributors Carousel with Real Data
  Widget _buildContributorCarousel() {
    if (isLoading) {
      return _buildLoadingCarousel("Frequent Contributors");
    }

    if (contributors.isEmpty) {
      return _buildEmptyCarousel("Frequent Contributors", "No contributors yet");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Frequent Contributors",
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        cs.CarouselSlider(
          items: contributors.map((contributor) => _buildUserCard(contributor, false)).toList(),
          options: cs.CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            viewportFraction: 0.45,
            enableInfiniteScroll: true,
          ),
        ),
      ],
    );
  }

  // Build user card for both artisans and contributors
 Widget _buildUserCard(Map<String, dynamic> user, bool isArtisan) {
    final name = user['name'] ?? 'Unknown User';
    final specialty = user['specialty'] ?? (isArtisan ? 'Crafting' : 'Donating');
    final profileImage = user['profile_image_url'];
    final donationCount = int.tryParse(user['donation_count']?.toString() ?? '0') ?? 0;
    final materialCount = int.tryParse(user['material_count']?.toString() ?? '0') ?? 0;
    final userId = user['id']?.toString() ?? '0';
    final availableGems = int.tryParse(user['available_gems']?.toString() ?? '0') ?? 0;

    return GestureDetector(
      onTap: () {
        _showUserProfileModal(context, name, userId);
      },
      child: Container(
        width: 140,
        height: 180, 
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12), 
            Container(
              width: 60, 
              height: 60, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFBEC092),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: profileImage != null 
                    ? Image.network(
                        profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildProfilePlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildProfilePlaceholder();
                        },
                      )
                    : _buildProfilePlaceholder(),
              ),
            ),
            const SizedBox(height: 8), 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _getDisplayName(name),
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                specialty,
                style: TextStyle(
                  fontSize: 12, 
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            if (donationCount > 0) ...[
              const SizedBox(height: 2),
              Text(
                '$donationCount donations',
                style: TextStyle(
                  fontSize: 10, 
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
             if (materialCount > 0) ...[
              Text(
                '$materialCount materials',
                style: TextStyle(
                  fontSize: 10, 
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (availableGems > 0) ...[
              Text(
                '$availableGems gems',
                style: TextStyle(
                  fontSize: 10, 
                  color: const Color(0xFF88844D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
             const SizedBox(height: 8), 
          ],
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

  String _getDisplayName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return '${parts[0]} ${parts[1][0]}.';
    }
    return fullName;
  }

  Widget _buildLoadingCarousel(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF88844D)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCarousel(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
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