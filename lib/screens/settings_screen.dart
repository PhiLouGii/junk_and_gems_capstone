import 'package:flutter/material.dart';
import 'package:junk_and_gems/providers/language_provider.dart';
import 'package:junk_and_gems/screens/legal_webview_screen.dart';
import 'package:junk_and_gems/utils/legal_content.dart';
import 'package:provider/provider.dart';

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
            _buildSettingItem(context, Icons.settings_applications_outlined, 'App Preferences', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppPreferencesScreen()),
              );
            }),
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
      {bool hasToggle = false, bool isDestructive = false, VoidCallback? onTap}) {
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
        onTap: onTap ?? () {
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

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  bool _isSesotho = false;
  double _fontSize = 1.0; // 1.0 = 100%, range from 0.8 to 1.5

  final List<double> _fontSizeOptions = [0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5];
  final Map<double, String> _fontSizeLabels = {
    0.8: 'Small',
    0.9: 'Small+',
    1.0: 'Medium',
    1.1: 'Medium+',
    1.2: 'Large',
    1.3: 'Large+',
    1.4: 'Extra Large',
    1.5: 'Extra Large+',
  };

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
          'App Preferences',
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
            _buildSectionHeader('LANGUAGE'),
            const SizedBox(height: 16),
            _buildLanguageToggle(),
            const SizedBox(height: 32),
            _buildSectionHeader('DISPLAY'),
            const SizedBox(height: 16),
            _buildFontSizeSlider(),
            const SizedBox(height: 16),
            _buildFontSizePreview(),
            const SizedBox(height: 32),
            _buildSectionHeader('PREVIEW'),
            const SizedBox(height: 16),
            _buildPreviewCard(),
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

  Widget _buildLanguageToggle() {
  return Consumer<LanguageProvider>(
    builder: (context, languageProvider, child) {
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
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFBEC092),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.language, color: Color(0xFF88844D), size: 20),
          ),
          title: Text(
            'App Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF88844D),
            ),
          ),
          subtitle: Text(
            languageProvider.isSesotho ? 'Sesotho' : 'English',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF88844D).withOpacity(0.7),
            ),
          ),
          trailing: Switch(
            value: languageProvider.isSesotho,
            onChanged: (value) {
              languageProvider.toggleLanguage(value);
            },
            activeColor: const Color(0xFF88844D),
          ),
        ),
      );
    },
  );
}


  Widget _buildFontSizeSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF88844D),
                ),
              ),
              Text(
                _fontSizeLabels[_fontSize] ?? 'Medium',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF88844D).withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _fontSize,
            min: 0.8,
            max: 1.5,
            divisions: 7, // 8 options total
            onChanged: (value) {
              setState(() {
                _fontSize = value;
              });
            },
            activeColor: const Color(0xFF88844D),
            inactiveColor: const Color(0xFFBEC092),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Small',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF88844D).withOpacity(0.6),
                ),
              ),
              Text(
                'Large',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF88844D).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizePreview() {
  return Consumer<LanguageProvider>(
    builder: (context, languageProvider, child) {
      return Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF88844D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              languageProvider.isSesotho
                  ? 'Ho lokile, kea utloa hantle!'
                  : 'This is how your text will look with the selected font size.',
              style: TextStyle(
                fontSize: 14 * _fontSize,
                color: const Color(0xFF88844D),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildPreviewCard() {
  return Consumer<LanguageProvider>(
    builder: (context, languageProvider, child) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.isSesotho ? 'Pono ea App' : 'App Preview',
              style: TextStyle(
                fontSize: 18 * _fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF88844D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.isSesotho
                  ? 'Sena ke mohlala o hlahisang hore sebatli se tla shebahala joang app ena.'
                  : 'This is a sample preview showing how the app interface will look.',
              style: TextStyle(
                fontSize: 14 * _fontSize,
                color: const Color(0xFF88844D).withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E5C2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.recycling,
                      color: const Color(0xFF88844D),
                      size: 20 * _fontSize),
                  const SizedBox(width: 8),
                  Text(
                    languageProvider.isSesotho
                        ? 'Ho fana ka Thepa'
                        : 'Donate Materials',
                    style: TextStyle(
                      fontSize: 14 * _fontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF88844D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
}