import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'package:junk_and_gems/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';
import 'create_listing_screen.dart';

class BrowseMaterialsScreen extends StatefulWidget {
  const BrowseMaterialsScreen({super.key});

  @override
  State<BrowseMaterialsScreen> createState() => _BrowseMaterialsScreenState();
}

class _BrowseMaterialsScreenState extends State<BrowseMaterialsScreen> {
  List<dynamic> _materials = [];
  List<dynamic> _filteredMaterials = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  Set<String> _claimedMaterialIds = {};

  final List<String> _categories = [
    'All',
    'Plastic',
    'Fabric',
    'Glass',
    'Wood',
    'Metal',
    'Electronics',
    'Cans',
    'Cables',
    'Paper',
    'Ceramics',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isInitialized) {
      print('⏳ Waiting for auth provider to initialize...');
      await authProvider.initialize();
      print('✅ Auth provider ready!');
    }
    _loadMaterials();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _filteredMaterials = materials;
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load materials: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _filterMaterials() {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      setState(() {
        _filteredMaterials = _materials;
      });
      return;
    }

    final filtered = _materials.where((material) {
      final matchesSearch = _searchQuery.isEmpty ? true : 
          material['title']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
          material['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
          material['category']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
          material['location']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true;

      final matchesCategory = _selectedCategory == null || 
                             _selectedCategory == 'All' ? true : 
          material['category']?.toString().toLowerCase() == _selectedCategory!.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    setState(() {
      _filteredMaterials = filtered;
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterMaterials();
  }

  void _handleCategorySelect(String category) {
    setState(() {
      _selectedCategory = category == 'All' ? null : category;
    });
    _filterMaterials();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _searchController.clear();
    });
    _filterMaterials();
  }

  Future<void> _claimMaterial(String materialId, String title) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('=' * 50);
    print('🎯 CLAIM MATERIAL ATTEMPT');
    print('User object: ${authProvider.user}');
    print('User ID: ${authProvider.user?.id}');
    print('User name: ${authProvider.user?.name}');
    print('Is authenticated: ${authProvider.isAuthenticated}');
    print('Is initialized: ${authProvider.isInitialized}');
    print('=' * 50);

    if (!authProvider.isAuthenticated || authProvider.user?.id == null) {
      print('❌ User not authenticated or ID is null');
      
      if (!authProvider.isInitialized) {
        print('🔄 Auth not initialized, initializing now...');
        await authProvider.initialize();
        
        if (!authProvider.isAuthenticated || authProvider.user?.id == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to claim materials'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to claim materials'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    print('✅ User authenticated, proceeding with claim...');

    try {
      print('🎯 Claiming material $materialId for user ${authProvider.user!.id}');
      
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3003/materials/$materialId/claim'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'claimed_by': authProvider.user!.id,
        }),
      );

      print('📡 Claim response status: ${response.statusCode}');
      print('📡 Claim response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _claimedMaterialIds.add(materialId);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully claimed $title! 🎉 +2 Gems earned'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        await _loadMaterials();
      } else {
        throw Exception('Failed to claim material: ${response.body}');
      }
    } catch (error) {
      print('❌ Error claiming material: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim material: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchSection(),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse Materials',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (!_isLoading && !_hasError)
                      Text(
                        '${_materials.length} items available',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF88844D),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildCategoryChips(),
          if (_searchQuery.isNotEmpty || _selectedCategory != null) ...[
            const SizedBox(height: 12),
            _buildActiveFiltersBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBEC092), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBEC092).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Icon(Icons.search, color: const Color(0xFF88844D), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search plastics, cans, fabrics...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: _handleSearch,
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, size: 20, color: const Color(0xFF88844D)),
                onPressed: () {
                  _searchController.clear();
                  _handleSearch('');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category || 
                            (category == 'All' && _selectedCategory == null);
          
          return GestureDetector(
            onTap: () => _handleCategorySelect(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? const LinearGradient(
                      colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                color: isSelected ? null : const Color(0xFFBEC092).withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? const Color(0xFF88844D) : const Color(0xFFBEC092).withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF88844D).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_circle, color: Colors.white, size: 16),
                    ),
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF88844D),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFBEC092).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBEC092).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 18, color: const Color(0xFF88844D)),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (_searchQuery.isNotEmpty)
                  _buildFilterChip(
                    label: '"$_searchQuery"',
                    icon: Icons.search,
                    onTap: () {
                      _searchController.clear();
                      _handleSearch('');
                    },
                  ),
                if (_selectedCategory != null)
                  _buildFilterChip(
                    label: _selectedCategory!,
                    icon: Icons.category,
                    onTap: () => _handleCategorySelect('All'),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all, size: 16, color: Color(0xFF88844D)),
            label: const Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFF88844D),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF88844D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onTap,
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_filteredMaterials.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildResultsHeader(),
        Expanded(child: _buildMaterialsGrid(context)),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF88844D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_filteredMaterials.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _filteredMaterials.length == 1 ? 'material found' : 'materials found',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsGrid(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMaterials,
      color: const Color(0xFF88844D),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid layout
          int crossAxisCount = 1;
          double childAspectRatio = 1.1;
          
          if (constraints.maxWidth > 600) {
            crossAxisCount = 2;
            childAspectRatio = 0.9;
          }
          if (constraints.maxWidth > 900) {
            crossAxisCount = 3;
            childAspectRatio = 0.85;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _filteredMaterials.length,
            itemBuilder: (context, index) {
              final material = _filteredMaterials[index];
              return _buildMaterialCard(context, material: material);
            },
          );
        },
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, {required dynamic material}) {
    final bool hasImages = material['image_urls'] != null && 
                        material['image_urls'].isNotEmpty;
    final String imageUrl = hasImages ? material['image_urls'][0] : '';
    final bool isClaimed = material['claimed_by'] != null || 
                          _claimedMaterialIds.contains(material['id'].toString());

    return GestureDetector(
      onTap: () => _showMaterialDetails(context, material: material),
      child: Hero(
        tag: 'material_${material['id']}',
        child: Container(
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
              // Image Section with overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      child: hasImages 
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF88844D),
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return _buildCategoryPlaceholder(material['category'] ?? 'General');
                              },
                            )
                          : _buildCategoryPlaceholder(material['category'] ?? 'General'),
                    ),
                  ),
                  
                  // Category badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        material['category'] ?? 'General',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF88844D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Claimed badge
                  if (isClaimed)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF88844D).withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'CLAIMED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        material['title'] ?? 'No Title',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Description
                      Expanded(
                        child: Text(
                          material['description'] ?? 'No description',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: const Color(0xFF88844D)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              material['location'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: isClaimed ? null : () {
                            _claimMaterial(material['id'].toString(), material['title']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isClaimed ? Colors.grey[400] : const Color(0xFFBEC092),
                            foregroundColor: isClaimed ? Colors.white : const Color(0xFF88844D),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: isClaimed ? 0 : 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isClaimed ? Icons.check : Icons.volunteer_activism,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isClaimed ? 'Claimed' : 'Claim It!',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPlaceholder(String category) {
    Map<String, Map<String, dynamic>> categoryStyles = {
      'plastic': {'icon': Icons.recycling, 'color': Colors.green},
      'fabric': {'icon': Icons.curtains, 'color': Colors.purple},
      'glass': {'icon': Icons.wine_bar, 'color': Colors.blue},
      'metal': {'icon': Icons.build, 'color': Colors.grey},
      'wood': {'icon': Icons.forest, 'color': Colors.brown},
      'electronics': {'icon': Icons.electrical_services, 'color': Colors.orange},
      'cans': {'icon': Icons.local_drink, 'color': Colors.blueGrey},
      'cables': {'icon': Icons.cable, 'color': Colors.deepOrange},
      'paper': {'icon': Icons.description, 'color': Colors.blue},
      'ceramics': {'icon': Icons.celebration, 'color': Colors.red},
    };

    final style = categoryStyles[category.toLowerCase()] ?? {
      'icon': Icons.category,
      'color': const Color(0xFFBEC092),
    };

    return Container(
      height: 160,
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
            size: 48,
            color: style['color'] as Color,
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: style['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
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
            'Loading materials...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finding the best recyclables for you',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t load the materials.\nPlease check your connection and try again.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadMaterials,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool hasFilters = _searchQuery.isNotEmpty || _selectedCategory != null;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
                size: 64,
                color: const Color(0xFF88844D),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No matches found' : 'No materials yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters 
                  ? 'Try adjusting your search or filters\nto find what you\'re looking for'
                  : 'Be the first to donate materials\nand help the community recycle!',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (hasFilters)
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBEC092),
                  foregroundColor: const Color(0xFF88844D),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateListingScreen()),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Donate Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF88844D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateListingScreen()),
        );
      },
      backgroundColor: const Color(0xFF88844D),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text(
        'Donate',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 4,
    );
  }

  void _showMaterialDetails(BuildContext context, {required dynamic material}) {
    final bool hasImages = material['image_urls'] != null && 
                        material['image_urls'].isNotEmpty;
    final String imageUrl = hasImages ? material['image_urls'][0] : '';
    final bool isClaimed = material['claimed_by'] != null || 
                          _claimedMaterialIds.contains(material['id'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  Expanded(
                    child: Text(
                      'Material Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with hero animation
                    Hero(
                      tag: 'material_${material['id']}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: hasImages
                            ? Image.network(
                                imageUrl,
                                height: 240,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildCategoryPlaceholder(material['category'] ?? 'General');
                                },
                              )
                            : _buildCategoryPlaceholder(material['category'] ?? 'General'),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Title and category
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            material['title'] ?? 'No Title',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        if (isClaimed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'CLAIMED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEC092).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBEC092).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category,
                            size: 16,
                            color: const Color(0xFF88844D),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            material['category'] ?? 'General',
                            style: const TextStyle(
                              color: Color(0xFF88844D),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      material['description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Details card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFBEC092).withOpacity(0.1),
                            const Color(0xFF88844D).withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFBEC092).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.person,
                            label: 'Uploaded by',
                            value: material['uploader'] ?? 'Unknown',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'Location',
                            value: material['location'] ?? 'Unknown location',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.inventory_2,
                            label: 'Quantity',
                            value: material['quantity']?.toString() ?? 'Not specified',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.access_time,
                            label: 'Posted',
                            value: material['time'] ?? 'Recently',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: isClaimed ? null : () {
                              Navigator.pop(context);
                              _claimMaterial(material['id'].toString(), material['title']);
                            },
                            icon: Icon(
                              isClaimed ? Icons.check_circle : Icons.volunteer_activism,
                              size: 20,
                            ),
                            label: Text(
                              isClaimed ? 'Already Claimed' : 'Claim Material',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isClaimed ? Colors.grey[400] : const Color(0xFF88844D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Message sent to ${material['uploader'] ?? 'uploader'}'),
                                  backgroundColor: const Color(0xFF88844D),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: const Text(
                              'Chat',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFBEC092), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF88844D).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF88844D)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
          _navItem(Icons.home_filled, false, 'Home', onTap: () {}),
          _navItem(Icons.inventory_2, true, 'Browse', onTap: () {}),
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