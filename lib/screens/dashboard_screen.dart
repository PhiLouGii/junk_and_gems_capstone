import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'browse_materials_screen.dart'; // Make sure this file exists

class DashboardScreen extends StatelessWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
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
                _buildImpactSection(),
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
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }

  // Welcome Card
  Widget _buildWelcomeCard() {
    return Center(
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome, $userName!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 96, 93, 54),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What will you do today?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.7),
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
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 85, 83, 48),
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
            _buildUpcycledCard('Beer Bottle Chair', 'assets/images/upcycled2.jpg'),
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
          color: const Color(0xFFE4E5C2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 28, color: const Color(0xFF88844D)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF88844D),
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
            Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
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
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to marketplace
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF88844D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Shop Now',
                          style: TextStyle(
                            color: Colors.white,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Impact',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF88844D)),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildImpactCell('150', 'pieces donated'),
              _buildImpactCell('4', 'Upcycled items bought'),
              _buildImpactCell('2500', 'Gems'),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 74, 72, 42),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.7)),
        ),
      ],
    );
  }

  // Artisan Carousel
  Widget _buildArtisanCarousel() {
    final items = _artisanHighlights();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Artisan Highlights",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF88844D)),
        ),
        const SizedBox(height: 12),
        cs.CarouselSlider(
          items: items,
          options: cs.CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            enlargeCenterPage: true,
            viewportFraction: 0.4,
          ),
        ),
      ],
    );
  }

  // Contributors Carousel
  Widget _buildContributorCarousel() {
    final items = _frequentContributors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Frequent Contributors",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF88844D)),
        ),
        const SizedBox(height: 12),
        cs.CarouselSlider(
          items: items,
          options: cs.CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            enlargeCenterPage: true,
            viewportFraction: 0.4,
          ),
        ),
      ],
    );
  }

  // Artisan Highlights
  List<Widget> _artisanHighlights() {
    final artisans = [
      {'name': 'Limakatso L.', 'specialty': 'Jewellery'},
      {'name': 'Nthati R.', 'specialty': 'Home Decor'},
      {'name': 'Bonn F.', 'specialty': 'Fashion'},
      {'name': 'Meredith G.', 'specialty': 'Furniture'},
      {'name': 'Miranda B.', 'specialty': 'Art & Crafts'},
      {'name': 'Cristina Y.', 'specialty': 'Home Decor'},
    ];

    return artisans.map((a) {
      return Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFE4E5C2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 40, color: Color(0xFFBEC092)),
            const SizedBox(height: 12),
            Text(
              a['name']!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D)),
              textAlign: TextAlign.center,
            ),
            if (a['specialty']!.isNotEmpty)
              Text(
                a['specialty']!,
                style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      );
    }).toList();
  }

  // Frequent Contributors
  List<Widget> _frequentContributors() {
    final contributors = [
      {'name': 'Richard W.', 'contribution': 'Fabric & Wood'},
      {'name': 'Mahloli M.', 'contribution': 'Plastic bottles'},
      {'name': 'Alex T.', 'contribution': 'Cables'},
      {'name': 'Liteboho N.', 'contribution': 'Wood'},
      {'name': 'Philippa G.', 'contribution': 'Cardboard'},
      {'name': 'Jackson A.', 'contribution': 'Old CDs'},
    ];

    return contributors.map((c) {
      return Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFE4E5C2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 40, color: Color(0xFFBEC092)),
            const SizedBox(height: 12),
            Text(
              c['name']!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF88844D)),
              textAlign: TextAlign.center,
            ),
            Text(
              c['contribution']!,
              style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }).toList();
  }

  // Bottom Nav Bar
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
          _navItem(Icons.home, true, onTap: () {}),
          _navItem(Icons.inventory_2_outlined, false, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
            );
          }),
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
        decoration: isSelected
            ? const BoxDecoration(color: Color(0xFFF7F2E4), shape: BoxShape.circle)
            : null,
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: const Color(0xFF88844D), size: 28),
      ),
    );
  }
}
