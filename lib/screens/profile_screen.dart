import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(),
              const SizedBox(height: 32),
              
              // Bio Section
              _buildBioSection(),
              const SizedBox(height: 32),
              
              // Divider
              Divider(
                color: const Color(0xFF88844D).withOpacity(0.3),
                thickness: 1,
              ),
              const SizedBox(height: 32),
              
              // Contact Information
              _buildContactInformation(),
              const SizedBox(height: 32),
              
              // My Account
              _buildMyAccount(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Profile Picture
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFBEC092),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.person,
            size: 60,
            color: const Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 24),
        
        // Name
        Text(
          'Deborah Pholo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 8),
        
        // Username
        Text(
          '@debblepholo',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF88844D).withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        
        // Join Date
        Text(
          'Joined in 2024',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF88844D).withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFBEC092),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: const Color(0xFF88844D).withOpacity(0.6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Add a little something about yourself...',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF88844D).withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 20),
        
        // Email
        _buildContactItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: 'debble.pholo@example.com',
        ),
        const SizedBox(height: 20),
        
        // Phone
        _buildContactItem(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: '+268 xxxx xxxx',
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
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
              child: Icon(
                icon,
                color: const Color(0xFF88844D),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF88844D).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF88844D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
        Text(
          'My Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF88844D),
          ),
        ),
        const SizedBox(height: 20),
        
        // My Purchases
        _buildAccountItem(
          icon: Icons.shopping_bag_outlined,
          label: 'My Purchases',
        ),
        const SizedBox(height: 12),
        
        // Settings
        _buildAccountItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
        ),
      ],
    );
  }

  Widget _buildAccountItem({
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
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
              child: Icon(
                icon,
                color: const Color(0xFF88844D),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF88844D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF88844D).withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}