// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/legal_webview_screen.dart';
import 'package:junk_and_gems/utils/legal_content.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('QUICK SETTINGS'),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.notifications_outlined, 'Notifications'),
            _buildSettingItem(context, Icons.dark_mode_outlined, 'Dark Mode', hasToggle: true),
            const SizedBox(height: 32),
            _buildSectionHeader('PREFERENCES'),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.payment_outlined, 'Payments & Earnings'),
            _buildSettingItem(context, Icons.settings_applications_outlined, 'App Preferences'),
            const SizedBox(height: 32),
            _buildSectionHeader('SUPPORT'),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.help_outline, 'Help & Support'),
            _buildSettingItem(context, Icons.info_outline, 'Legal & Info'),
            const SizedBox(height: 32),
            _buildSectionHeader('ACCOUNT'),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.logout_outlined, 'Sign Out', isDestructive: true),
            _buildSettingItem(context, Icons.delete_outline, 'Delete Account', isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF88844D).withOpacity(0.8),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title,
      {bool hasToggle = false, bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withOpacity(0.1) : const Color(0xFFBEC092),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF88844D), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : const Color(0xFF88844D),
          ),
        ),
        trailing: hasToggle
            ? Switch(
                value: false,
                onChanged: (_) {},
                activeColor: const Color(0xFF88844D),
              )
            : Icon(Icons.arrow_forward_ios,
                color: isDestructive ? Colors.red.withOpacity(0.6) : const Color(0xFF88844D).withOpacity(0.6),
                size: 16),
        onTap: () {
          if (title == 'Sign Out') {
            _showSignOutDialog(context);
          } else if (title == 'Delete Account') {
            _showDeleteAccountDialog(context);
          } else if (title == 'Legal & Info') {
            _launchLegalInfo(context);
          }
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF7F2E4),
        title: const Text('Sign Out', style: TextStyle(color: Color(0xFF88844D), fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Color(0xFF88844D))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF88844D)))),
          TextButton(onPressed: () {}, child: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF7F2E4),
        title: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.', style: TextStyle(color: Color(0xFF88844D))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF88844D)))),
          TextButton(onPressed: () {}, child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _launchLegalInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalWebViewScreen(
          title: 'Legal & Information',
          htmlContent: LegalContent.legalInfo,
        ),
      ),
    );
  }
}
