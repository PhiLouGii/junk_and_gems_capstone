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
      
      if (lastRewardCheck != today) {
        final rewardResponse = await UserService.claimDailyReward(widget.userId);
        
        if (rewardResponse['success'] == true) {
          setState(() {
            dailyRewardData = rewardResponse;
            showDailyReward = true;
          });
          
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

      setState(() {
        artisans = artisansData;
        contributors = contributorsData;
        userImpact = impactData;
        isLoading = false;
      });
      
      await _saveDataToCache(artisansData, contributorsData, impactData);
      
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
    } catch (e) {
      print('❌ Error saving data to cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF88844D),
              child: OrientationBuilder(
                builder: (context, orientation) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isLandscape = orientation == Orientation.landscape;
                      final maxWidth = constraints.maxWidth;
                      
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: maxWidth > 600 ? 24.0 : 16.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(maxWidth),
                              const SizedBox(height: 16),
                              
                              if (isLandscape)
                                _buildLandscapeLayout(maxWidth)
                              else
                                _buildPortraitLayout(maxWidth),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            if (showDailyReward && dailyRewardData != null)
              DailyRewardPopup(
                gemsEarned: dailyRewardData!['gems_earned'] ?? 5,
                currentStreak: dailyRewardData!['streak'] ?? 1,
                streakBonus: dailyRewardData!['streak_bonus'] ?? 0,
                onClose: () {
                  setState(() {
                    showDailyReward = false;
                  });
                  _loadData();
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(double maxWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: maxWidth > 600 ? 120 : 100,
                height: maxWidth > 600 ? 120 : 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.help_outline,
                color: const Color(0xFF88844D),
                size: 28,
              ),
              onPressed: () {
                _showHelpDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeCard(maxWidth),
        const SizedBox(height: 24),
        _buildActionButtons(maxWidth),
        const SizedBox(height: 24),
        _buildProductItems(maxWidth),
        const SizedBox(height: 24),
        _buildArtisanHighlights(maxWidth),
        const SizedBox(height: 24),
        _buildFrequentContributors(maxWidth),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLandscapeLayout(double maxWidth) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildWelcomeCard(maxWidth),
                  const SizedBox(height: 16),
                  _buildActionButtons(maxWidth),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildProductItems(maxWidth),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildArtisanHighlights(maxWidth),
        const SizedBox(height: 24),
        _buildFrequentContributors(maxWidth),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWelcomeCard(double maxWidth) {
    final gemsEarned = userImpact['gems_earned']?.toString() ?? '0';
    final isLargeScreen = maxWidth > 600;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFBEC092).withOpacity(0.3),
            const Color(0xFF88844D).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBEC092).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 20 : 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF88844D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What will you do today?',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 16 : 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildGemsCircle(gemsEarned, isLargeScreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGemsCircle(String gemsEarned, bool isLargeScreen) {
    final size = isLargeScreen ? 130.0 : 110.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF88844D),
            const Color(0xFFBEC092),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              color: const Color(0xFF88844D),
              size: isLargeScreen ? 36 : 32,
            ),
            const SizedBox(height: 4),
            Text(
              gemsEarned,
              style: TextStyle(
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              'Gems',
              style: TextStyle(
                fontSize: isLargeScreen ? 14 : 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(double maxWidth) {
    final isLargeScreen = maxWidth > 600;
    
    return Row(
      children: [
        Expanded(
          child: _buildMaterialButton(
            'Donate Materials', 
            Icons.add_circle_outline, 
            true, 
            maxWidth
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMaterialButton(
            'Browse Materials', 
            Icons.search, 
            false, 
            maxWidth
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialButton(String text, IconData icon, bool isDonate, double maxWidth) {
    final isLargeScreen = maxWidth > 600;
    
    return GestureDetector(
      onTap: () {
        if (isDonate) {
          print('Donate Materials pressed');
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
          );
        }
      },
      child: Container(
        height: isLargeScreen ? 100 : 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDonate 
              ? [const Color(0xFF88844D), const Color(0xFFBEC092)]
              : [const Color(0xFFBEC092), const Color(0xFF88844D)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF88844D).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isLargeScreen ? 28 : 24,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItems(double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF88844D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.stars,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Featured Items',
              style: TextStyle(
                fontSize: maxWidth > 600 ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 3;
            if (constraints.maxWidth < 400) {
              crossAxisCount = 2;
            } else if (constraints.maxWidth > 700) {
              crossAxisCount = 4;
            }
            
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildProductItem('Denim Handbag', 'assets/images/upcycled1.jpg', maxWidth),
                _buildProductItem('Bottle Wall Art', 'assets/images/upcycled2.jpg', maxWidth),
                _buildProductItem('Buttons Figure', 'assets/images/upcycled3.jpg', maxWidth),
                _buildProductItem('Wine Cork Coasters', 'assets/images/upcycled4.jpg', maxWidth),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductItem(String title, String imagePath, double maxWidth) {
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF88844D).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFBEC092).withOpacity(0.3),
                                const Color(0xFF88844D).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shopping_bag,
                              size: maxWidth > 600 ? 40 : 32,
                              color: const Color(0xFF88844D),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: const Color(0xFF88844D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: maxWidth > 600 ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtisanHighlights(double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.palette,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Artisan Highlights',
              style: TextStyle(
                fontSize: maxWidth > 600 ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (isLoading)
          _buildLoadingSection()
        else if (artisans.isEmpty)
          _buildEmptySection('No artisans available')
        else
          SizedBox(
            height: maxWidth > 600 ? 160 : 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: artisans.length,
              itemBuilder: (context, index) {
                return _buildUserCard(artisans[index], true, maxWidth);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFrequentContributors(double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF88844D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.volunteer_activism,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Frequent Contributors',
              style: TextStyle(
                fontSize: maxWidth > 600 ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (isLoading)
          _buildLoadingSection()
        else if (contributors.isEmpty)
          _buildEmptySection('No contributors available')
        else
          SizedBox(
            height: maxWidth > 600 ? 160 : 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: contributors.length,
              itemBuilder: (context, index) {
                return _buildUserCard(contributors[index], false, maxWidth);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isArtisan, double maxWidth) {
    final name = user['name'] ?? 'Unknown User';
    final specialty = user['specialty'] ?? (isArtisan ? 'Artisan' : 'Contributor');
    final profileImage = user['profile_image_url'];
    final userId = user['id']?.toString() ?? '0';
    final isLargeScreen = maxWidth > 600;

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
        width: isLargeScreen ? 140 : 125,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFBEC092).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF88844D).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isLargeScreen ? 14.0 : 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: isLargeScreen ? 60 : 55,
                    height: isLargeScreen ? 60 : 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFBEC092),
                          const Color(0xFF88844D),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: profileImage != null && profileImage.isNotEmpty
                            ? Image.network(
                                getImageUrlWithCacheBust(profileImage),
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF88844D),
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildProfilePlaceholder(isLargeScreen);
                                },
                              )
                            : _buildProfilePlaceholder(isLargeScreen),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF88844D),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        isArtisan ? Icons.palette : Icons.volunteer_activism,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              Text(
                _getDisplayName(name),
                style: TextStyle(
                  fontSize: isLargeScreen ? 13 : 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBEC092).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF88844D),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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

  Widget _buildProfilePlaceholder(bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFBEC092).withOpacity(0.3),
            const Color(0xFF88844D).withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: isLargeScreen ? 28 : 24,
        color: const Color(0xFF88844D),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBEC092).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFF88844D),
              strokeWidth: 3,
            ),
            const SizedBox(height: 12),
            Text(
              'Loading...',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBEC092).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 36,
              color: const Color(0xFF88844D).withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF88844D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Help & Info'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                icon: Icons.star,
                title: 'Earn Gems',
                description: 'Collect gems by donating materials and claiming items from others.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.add_circle_outline,
                title: 'Donate Materials',
                description: 'Share recyclable materials with the community and earn gems.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.search,
                title: 'Browse Materials',
                description: 'Find materials others have donated and claim what you need.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.shopping_bag,
                title: 'Marketplace',
                description: 'Buy upcycled products from talented artisans in the community.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF88844D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFBEC092).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF88844D),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userName: widget.userName,
                  userId: widget.userId,
                ),
              ),
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