import 'package:flutter/material.dart';

class BrowseMaterialsScreen extends StatelessWidget {
  const BrowseMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with back button and logo
            _buildHeader(context),

            // Search Bar
            _buildSearchBar(),

            // Category Chips
            _buildCategoryChips(),

            // Materials List
            Expanded(
              child: _buildMaterialsList(),
            ),

            // Donate Materials Button
            _buildDonateButton(),
          ],
        ),
      ),
    );
  }

  // Header with back arrow and centered logo + text
Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: Row(
      children: [
        // Back button on the left
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // Centered logo + text
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(width: 8),
              const Text(
                'Materials',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF88844D),
                ),
              ),
            ],
          ),
        ),

        // Placeholder to balance the row (same width as back button)
        const SizedBox(width: 48),
      ],
    ),
  );
}


  // Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFBEC092),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: const Color(0xFF88844D).withOpacity(0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for plastics, cans, fabrics...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF88844D).withOpacity(0.6),
                    ),
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

  // Category chips as tags
  Widget _buildCategoryChips() {
    final categories = ['Plastic', 'Fabric', 'Glass', 'Wood', 'Cans','Cables'];

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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              backgroundColor: const Color(0xFFBEC092),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            );
          },
        ),
      ),
    );
  }

  // Materials list
  Widget _buildMaterialsList() {
    final materials = [
      {
        'title': 'Plastic bottles',
        'description': '30 bottles (500ml size)',
        'location': 'Tona-Kholo Road',
        'time': '2 hrs ago',
        'image': 'assets/images/plastic_bottles.jpg'
      },
      {
        'title': 'Bottle caps',
        'description': '200 + caps',
        'location': 'Ha Thetsane',
        'time': '4 hrs ago',
        'image': 'assets/images/bottle_caps.jpg'
      },
      {
        'title': 'Old Jeans',
        'description': '10 pcs',
        'location': 'Masowe II',
        'time': '3 days ago',
        'image': 'assets/images/old_jeans.jpg'
      },
      {
        'title': 'Old CDs',
        'description': '130 pcs',
        'location': 'Maseru West',
        'time': '4 days ago',
        'image': 'assets/images/old_cds.jpg'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return _buildMaterialCard(
          title: material['title']!,
          description: material['description']!,
          location: material['location']!,
          time: material['time']!,
          imagePath: material['image']!,
        );
      },
    );
  }

  // Material card with image
  Widget _buildMaterialCard({
    required String title,
    required String description,
    required String location,
    required String time,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF88844D),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBEC092),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Claim',
                            style: TextStyle(
                              color: Color(0xFF88844D),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFBEC092), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Details',
                            style: TextStyle(
                              color: Color(0xFF88844D),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
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

  // Donate button
  Widget _buildDonateButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF88844D),
            foregroundColor: const Color(0xFFF7F2E4),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Donate Materials',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFBEC092),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, false, onTap: () {
            Navigator.pop(context); // Go back to dashboard
          }),
          _navItem(Icons.inventory_2_outlined, true, onTap: () {}),
          _navItem(Icons.shopping_bag_outlined, false),
          _navItem(Icons.notifications_active_outlined, false),
          _navItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isSelected
            ? const BoxDecoration(color: Color(0xFFF7F2E4), shape: BoxShape.circle)
            : null,
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: const Color(0xFF88844D), size: 28),
      ),
    );
  }
}
