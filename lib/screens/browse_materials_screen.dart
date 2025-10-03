import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'package:junk_and_gems/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'create_listing_screen.dart';

class BrowseMaterialsScreen extends StatefulWidget {
  const BrowseMaterialsScreen({super.key});

  @override
  State<BrowseMaterialsScreen> createState() => _BrowseMaterialsScreenState();
}

class _BrowseMaterialsScreenState extends State<BrowseMaterialsScreen> {
  List<dynamic> _materials = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      print('🔄 Loading materials from: http://10.0.2.2:3003/materials');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3003/materials'),
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> materials = json.decode(response.body);
        print('✅ Loaded ${materials.length} materials');
        
        setState(() {
          _materials = materials;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        print('❌ Server error: ${response.statusCode}');
        throw Exception('Failed to load materials: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Error loading materials: $error');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load materials: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _claimMaterial(String materialId, String title) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3003/materials/$materialId/claim'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'claimed_by': 1, // Replace with actual user ID from auth
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully claimed $title')),
        );
        _loadMaterials();
      } else {
        throw Exception('Failed to claim material');
      }
    } catch (error) {
      print('Error claiming material: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to claim material: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildCategoryChips(),
            Expanded(child: _buildMaterialsList(context)),
            _buildDonateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                Image.asset('assets/images/logo.png', width: 100, height: 100),
                const SizedBox(width: 8),
                Text(
                  'Materials',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBEC092), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.search, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: 'Search for plastics, cans, fabrics...',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['Plastic', 'Fabric', 'Glass', 'Wood', 'Cans', 'Cables'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return Chip(
              label: Text(
                categories[index],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              backgroundColor: const Color(0xFFBEC092),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaterialsList(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Theme.of(context).textTheme.bodyLarge?.color),
            const SizedBox(height: 16),
            Text(
              'Loading materials...',
              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).textTheme.bodyLarge?.color),
            const SizedBox(height: 16),
            Text(
              'Failed to load materials',
              style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMaterials,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBEC092),
                foregroundColor: const Color(0xFF88844D),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).textTheme.bodyLarge?.color),
            const SizedBox(height: 16),
            Text(
              'No materials available yet',
              style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to donate materials!',
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateListingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: const Color(0xFFF7F2E4),
              ),
              child: const Text('Donate Now'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMaterials,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _materials.length,
        itemBuilder: (context, index) {
          final material = _materials[index];
          return _buildMaterialCard(
            context,
            material: material,
          );
        },
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, {required dynamic material}) {
    final bool hasImages = material['image_urls'] != null && 
                        material['image_urls'].isNotEmpty;
  
    final String imageUrl = hasImages 
        ? material['image_urls'][0] 
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: hasImages && imageUrl.startsWith('data:image')
                ? Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildCategoryPlaceholder(material['category'] ?? 'General');
                    },
                  )
                : _buildCategoryPlaceholder(material['category'] ?? 'General'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['title'] ?? 'No Title',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 6),
                Text(
                  material['description'] ?? 'No description',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                    const SizedBox(width: 4),
                    Text(
                      material['location'] ?? 'Unknown location',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                    const SizedBox(width: 4),
                    Text(
                      material['time'] ?? 'Recently',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _claimMaterial(material['id'].toString(), material['title']);
                        },
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(color: const Color(0xFFBEC092), borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                            child: Text('Claim', style: TextStyle(color: Color(0xFF88844D), fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showMaterialDetails(context, material: material),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFBEC092), width: 2), borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Text('Details', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPlaceholder(String category) {
    // Define colors and icons for each category
    Map<String, Map<String, dynamic>> categoryStyles = {
      'plastic': {
        'icon': Icons.recycling,
        'color': Colors.green,
        'name': 'Plastic',
      },
      'fabric': {
        'icon': Icons.curtains,
        'color': Colors.purple,
        'name': 'Fabric',
      },
      'glass': {
        'icon': Icons.wine_bar,
        'color': Colors.blue,
        'name': 'Glass',
      },
      'metal': {
        'icon': Icons.build,
        'color': Colors.grey,
        'name': 'Metal',
      },
      'wood': {
        'icon': Icons.forest,
        'color': Colors.brown,
        'name': 'Wood',
      },
      'electronics': {
        'icon': Icons.electrical_services,
        'color': Colors.orange,
        'name': 'Electronics',
      },
      'cans': {
        'icon': Icons.local_drink,
        'color': Colors.blueGrey,
        'name': 'Cans',
      },
      'cables': {
        'icon': Icons.cable,
        'color': Colors.deepOrange,
        'name': 'Cables',
      },
    };

    // Get the style for the category, or use default
    final style = categoryStyles[category.toLowerCase()] ?? {
      'icon': Icons.category,
      'color': const Color(0xFFBEC092),
      'name': category,
    };

    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            style['color']!.withOpacity(0.3),
            style['color']!.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            style['icon'] as IconData,
            size: 50,
            color: style['color'] as Color,
          ),
          const SizedBox(height: 8),
          Text(
            style['name'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: style['color'] as Color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No image available',
            style: TextStyle(
              fontSize: 12,
              color: (style['color'] as Color).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaterialDetails(BuildContext context, {required dynamic material}) {
    final bool hasImages = material['image_urls'] != null && 
                        material['image_urls'].isNotEmpty;
  
    final String imageUrl = hasImages 
        ? material['image_urls'][0] 
        : '';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasImages && imageUrl.startsWith('data:image')
                        ? Image.network(
                            imageUrl,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildCategoryPlaceholder(material['category'] ?? 'General');
                            },
                          )
                        : _buildCategoryPlaceholder(material['category'] ?? 'General'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    material['title'] ?? 'No Title',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    material['description'] ?? 'No description',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Uploaded by: ${material['uploader'] ?? 'Unknown'}",
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Amount: ${material['quantity'] ?? 'Not specified'}",
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Location: ${material['location'] ?? 'Unknown location'}",
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Uploaded: ${material['time'] ?? 'Recently'}",
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _claimMaterial(material['id'].toString(), material['title']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBEC092),
                            foregroundColor: const Color(0xFF88844D),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Claim"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Message sent to uploader of ${material['title']}')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBEC092), width: 2),
                            backgroundColor: Theme.of(context).cardColor,
                            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Message"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateListingScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF88844D),
            foregroundColor: const Color(0xFFF7F2E4),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Donate Materials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
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
          _navItem(Icons.home_filled, false, 'Home', onTap: () {}),
          _navItem(Icons.inventory_2_outlined, true, 'Browse', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
            );
          }),
          _navItem(Icons.shopping_bag_outlined, false, 'Shop', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MarketplaceScreen(userName: 'User'),
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
 MaterialPageRoute(builder: (context) => const ProfileScreen(userName: 'User', userId: '')),
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