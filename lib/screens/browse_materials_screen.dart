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
  List<dynamic> _filteredMaterials = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  // Common material categories
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load materials: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
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
            _buildActiveFilters(),
            _buildCategoryChips(),
            _buildResultsInfo(),
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
                  controller: _searchController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: 'Search for plastics, cans, fabrics...',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    border: InputBorder.none,
                  ),
                  onChanged: _handleSearch,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearch('');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    final hasActiveFilters = _searchQuery.isNotEmpty || _selectedCategory != null;
    
    if (!hasActiveFilters) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            'Filters:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(width: 8),
          if (_searchQuery.isNotEmpty)
            _buildFilterChip(
              label: 'Search: "$_searchQuery"',
              onTap: () {
                _searchController.clear();
                _handleSearch('');
              },
            ),
          if (_selectedCategory != null)
            _buildFilterChip(
              label: 'Category: $_selectedCategory',
              onTap: () => _handleCategorySelect('All'),
            ),
          const Spacer(),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: const Color(0xFF88844D),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF88844D),
        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
        onDeleted: onTap,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: 40,
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF88844D) : const Color(0xFFBEC092).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF88844D) : const Color(0xFFBEC092),
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF88844D),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsInfo() {
    if (_isLoading || _hasError) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            '${_filteredMaterials.length} material${_filteredMaterials.length == 1 ? '' : 's'} found',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (_searchQuery.isNotEmpty || _selectedCategory != null)
            Text(
              '${_materials.length} total',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
        ],
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

    if (_filteredMaterials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _selectedCategory != null ? 
                Icons.search_off : Icons.inventory_2_outlined, 
              size: 64, 
              color: Theme.of(context).textTheme.bodyLarge?.color
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != null ? 
                'No materials found' : 'No materials available yet',
              style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != null ? 
                'Try adjusting your search or filters' : 'Be the first to donate materials!',
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_searchQuery.isNotEmpty || _selectedCategory != null)
              ElevatedButton(
                onPressed: _clearFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBEC092),
                  foregroundColor: const Color(0xFF88844D),
                ),
                child: const Text('Clear Filters'),
              )
            else
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
        itemCount: _filteredMaterials.length,
        itemBuilder: (context, index) {
          final material = _filteredMaterials[index];
          return _buildMaterialCard(context, material: material);
        },
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, {required dynamic material}) {
    final bool hasImages = material['image_urls'] != null && 
                        material['image_urls'].isNotEmpty;
    final String imageUrl = hasImages ? material['image_urls'][0] : '';
    final bool isClaimed = material['claimed_by'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2)
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        material['title'] ?? 'No Title',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEC092).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        material['category'] ?? 'General',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF88844D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  material['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Location and Time
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        material['location'] ?? 'Unknown location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    Icon(Icons.access_time, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                    const SizedBox(width: 4),
                    Text(
                      material['time'] ?? 'Recently',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                
                // Quantity
                if (material['quantity'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.inventory_2, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                      const SizedBox(width: 4),
                      Text(
                        'Quantity: ${material['quantity']!}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isClaimed ? null : () {
                          _claimMaterial(material['id'].toString(), material['title']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isClaimed ? Colors.grey : const Color(0xFFBEC092),
                          foregroundColor: isClaimed ? Colors.white : const Color(0xFF88844D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(isClaimed ? 'Claimed' : 'Claim'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showMaterialDetails(context, material: material),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBEC092), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Details',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
            size: 50,
            color: style['color'] as Color,
          ),
          const SizedBox(height: 8),
          Text(
            category,
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
    final String imageUrl = hasImages ? material['image_urls'][0] : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Material Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasImages
                          ? Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildCategoryPlaceholder(material['category'] ?? 'General');
                              },
                            )
                          : _buildCategoryPlaceholder(material['category'] ?? 'General'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      material['title'] ?? 'No Title',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEC092).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        material['category'] ?? 'General',
                        style: const TextStyle(
                          color: Color(0xFF88844D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      material['description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Details Grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.person,
                            label: 'Uploaded by',
                            value: material['uploader'] ?? 'Unknown',
                          ),
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'Location',
                            value: material['location'] ?? 'Unknown location',
                          ),
                          _buildDetailRow(
                            icon: Icons.inventory_2,
                            label: 'Quantity',
                            value: material['quantity'] ?? 'Not specified',
                          ),
                          _buildDetailRow(
                            icon: Icons.access_time,
                            label: 'Posted',
                            value: material['time'] ?? 'Recently',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Claim Material',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Message sent to ${material['uploader'] ?? 'uploader'}')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFBEC092), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Message',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF88844D)),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateListingScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF88844D),
            foregroundColor: const Color(0xFFF7F2E4),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 20),
              SizedBox(width: 8),
              Text(
                'Donate Materials',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
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