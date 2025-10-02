import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/screens/browse_materials_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/notfications_messages_screen.dart';
import 'package:junk_and_gems/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String bioText = "";
  Map<String, String> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userData = {
          'name': prefs.getString('userName') ?? 'User',
          'email': prefs.getString('userEmail') ?? '',
          'username': prefs.getString('username') ?? '',
        };
      });
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F2E4),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF88844D),
          ),
        ),
      );
    }

    final userName = userData['name'] ?? 'User';
    final userEmail = userData['email'] ?? '';
    final username = userData['username']?.isNotEmpty == true 
        ? userData['username'] 
        : (userEmail.split('@').first);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen(userName: userName)),
          ),
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
              _buildProfileHeader(userName, username),
              const SizedBox(height: 32),
              _buildBioSection(),
              const SizedBox(height: 32),
              Divider(
                color: const Color(0xFF88844D).withOpacity(0.3),
                thickness: 1,
              ),
              const SizedBox(height: 32),
              _buildContactInformation(userEmail),
              const SizedBox(height: 32),
              _buildMyAccount(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, userName),
    );
  }

  Widget _buildProfileHeader(String userName, String username) {
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
        Text(
          userName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username',
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
                counterText: "",
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

  Widget _buildContactInformation(String userEmail) {
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
          value: userEmail,
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
        _buildAccountItem(icon: Icons.shopping_bag_outlined, label: 'My Purchases', onTap: () {}),
        const SizedBox(height: 12),
        _buildAccountItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildAccountItem({required IconData icon, required String label, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFBEC092),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF88844D), size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF88844D), fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: const Color(0xFF88844D).withOpacity(0.6),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, String userName) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
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
          _navItem(Icons.home_filled, false, 'Home', onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen(userName: userName)),
              (route) => false,
            );
          }),
          _navItem(Icons.inventory_2_outlined, false, 'Browse', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BrowseMaterialsScreen(userName: userName)),
            );
          }),
          _navItem(Icons.shopping_bag_outlined, false, 'Shop', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketplaceScreen(userName: userName),
              ),
            );
          }),
          _navItem(Icons.notifications_outlined, false, 'Alerts', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsMessagesScreen()),
            );
          }),
          _navItem(Icons.person_outline, true, 'Profile', onTap: () {
            // Already on profile screen
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