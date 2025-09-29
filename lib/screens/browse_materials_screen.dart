import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'create_listing_screen.dart';

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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 100, height: 100),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBEC092), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.search, color: const Color(0xFF88844D).withOpacity(0.6)),
              const SizedBox(width: 12),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for plastics, cans, fabrics...',
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
    final materials = [
      {
        'title': 'Plastic bottles',
        'description': '30 bottles (500ml size)',
        'location': 'Tona-Kholo Road',
        'time': '2 hrs ago',
        'image': 'assets/images/plastic_bottles.jpg',
        'uploader': 'Limakatso Liphoto',
        'amount': '30 bottles'
      },
      {
        'title': 'Bottle caps',
        'description': '200+ caps',
        'location': 'Ha Thetsane',
        'time': '4 hrs ago',
        'image': 'assets/images/bottle_caps.jpg',
        'uploader': 'Nthati Raditapole',
        'amount': '200 caps'
      },
      {
        'title': 'Old Jeans',
        'description': '10 pcs',
        'location': 'Masowe II',
        'time': '3 days ago',
        'image': 'assets/images/old_jeans.jpg',
        'uploader': 'Mahloli Makhetha',
        'amount': '10 pcs'
      },
      {
        'title': 'Old CDs',
        'description': '130 pcs',
        'location': 'Maseru West',
        'time': '4 days ago',
        'image': 'assets/images/old_cds.jpg',
        'uploader': 'Deborah Pholo',
        'amount': '130 pcs'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return _buildMaterialCard(
          context,
          title: material['title']!,
          description: material['description']!,
          location: material['location']!,
          time: material['time']!,
          imagePath: material['image']!,
          uploader: material['uploader']!,
          amount: material['amount']!,
        );
      },
    );
  }

  Widget _buildMaterialCard(
    BuildContext context, {
    required String title,
    required String description,
    required String location,
    required String time,
    required String imagePath,
    required String uploader,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(imagePath, height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF88844D))),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 4),
                    Text(location, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6))),
                    const Spacer(),
                    const Icon(Icons.access_time, size: 16, color: Color(0xFF88844D)),
                    const SizedBox(width: 4),
                    Text(time, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Claimed $title')));
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
                        onTap: () => _showMaterialDetails(
                          context,
                          title: title,
                          description: description,
                          location: location,
                          time: time,
                          uploader: uploader,
                          amount: amount,
                          imagePath: imagePath,
                        ),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFBEC092), width: 2), borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                            child: Text('Details', style: TextStyle(color: Color(0xFF88844D), fontWeight: FontWeight.w600, fontSize: 14)),
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

  void _showMaterialDetails(
  BuildContext context, {
  required String title,
  required String description,
  required String location,
  required String time,
  required String uploader,
  required String amount,
  required String imagePath,
}) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
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
                  child: Image.asset(imagePath, height: 140, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF88844D))),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 8),
                Text("Uploaded by: $uploader", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 4),
                Text("Amount: $amount", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 4),
                Text("Location: $location", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 4),
                Text("Uploaded: $time", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Claimed $title')));
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message sent to uploader of $title')));
                        },
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBEC092), width: 2),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF88844D),
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
          _navItem(Icons.home, false, onTap: () => Navigator.pop(context)),
          _navItem(Icons.inventory_2_outlined, true),
          _navItem(Icons.shopping_bag_outlined, false),
          _navItem(Icons.notifications_active_outlined, false, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsMessagesScreen()),
            );
          }),
          _navItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isSelected ? const BoxDecoration(color: Color(0xFFF7F2E4), shape: BoxShape.circle) : null,
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: const Color(0xFF88844D), size: 28),
      ),
    );
  }
}
