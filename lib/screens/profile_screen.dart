import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/browse_materials_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String bioText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () => Navigator.pushReplacementNamed(context, 'DashboardScreen'),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/logo.png", height: 64), 
            const SizedBox(width: 8),
            const Text(
              "Profile",
              style: TextStyle(
                color: Color(0xFF88844D),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildBioSection(),
              const SizedBox(height: 32),
              Divider(
                color: const Color(0xFF88844D).withOpacity(0.3),
                thickness: 1,
              ),
              const SizedBox(height: 32),
              _buildContactInformation(),
              const SizedBox(height: 32),
              _buildMyAccount(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            // Profile Picture
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF88844D),
              ),
            ),
            // Edit button for profile picture
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Upload new profile picture logic here
                },
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, size: 18, color: Color(0xFF88844D)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Deborah Pholo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@debblepholo',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF88844D).withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Gems Counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.star, color: Colors.green, size: 18),
              SizedBox(width: 4),
              Text(
                "1250 Gems",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            TextField(
              maxLength: 120,
              onChanged: (value) => setState(() => bioText = value),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                filled: true,
                fillColor: Colors.white,
                hintText: "Add a little something about yourself...",
                hintStyle: TextStyle(
                  color: const Color(0xFF88844D).withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFBEC092)),
                ),
                counterText: "", // Hide default counter
              ),
            ),
            Positioned(
              bottom: 8,
              right: 16,
              child: Text(
                "${bioText.length}/120",
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF88844D).withOpacity(0.6),
                ),
              ),
            ),
            // Edit button for bio
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  // Edit bio logic
                },
                child: const Icon(Icons.edit, size: 18, color: Color(0xFF88844D)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 20),
        _buildContactItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: 'debble.pholo@example.com',
        ),
        const SizedBox(height: 20),
        _buildContactItem(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: '+266 xxxx xxxx',
        ),
      ],
    );
  }

  Widget _buildContactItem({required IconData icon, required String label, required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF88844D), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 14, color: const Color(0xFF88844D).withOpacity(0.7))),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF88844D), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 20),
        _buildAccountItem(icon: Icons.shopping_bag_outlined, label: 'My Purchases'),
        const SizedBox(height: 12),
        _buildAccountItem(icon: Icons.settings_outlined, label: 'Settings'),
      ],
    );
  }

  Widget _buildAccountItem({required IconData icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF88844D), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF88844D), fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.arrow_forward_ios, color: const Color(0xFF88844D).withOpacity(0.6), size: 16),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// Bottom Navigation Bar
  /// =========================
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
          _navItem(Icons.person_2_outlined, true, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }),
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
