import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/payments_earnings_screen.dart';
import 'package:junk_and_gems/providers/language_provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/screens/legal_webview_screen.dart';
import 'package:junk_and_gems/utils/legal_content.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
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
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return _buildSettingItem(
                  context, 
                  Icons.dark_mode_outlined, 
                  'Dark Mode', 
                  hasToggle: true,
                  switchValue: themeProvider.isDarkMode,
                  onSwitchChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('PREFERENCES'),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.payment_outlined, 'Payments & Earnings', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentsEarningsScreen()),
        );
      }),
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
    return Builder(builder: (context) => Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
        letterSpacing: 1.2,
      ),
    ));
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title,
      {bool hasToggle = false, 
       bool isDestructive = false, 
       VoidCallback? onTap,
       bool? switchValue,
       Function(bool)? onSwitchChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            color: isDestructive ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: hasToggle
            ? Switch(
                value: switchValue ?? false,
                onChanged: onSwitchChanged,
                activeColor: const Color(0xFF88844D),
              )
            : Icon(Icons.arrow_forward_ios,
                color: isDestructive ? Colors.red.withOpacity(0.6) : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
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
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Sign Out', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))
          ),
          TextButton(
            onPressed: () {}, 
            child: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('This action cannot be undone. All your data will be permanently deleted.', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))
          ),
          TextButton(
            onPressed: () {}, 
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
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
  double _fontSize = 1.0;

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'App Preferences',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
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
        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              languageProvider.isSesotho ? 'Sesotho' : 'English',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
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
        color: Theme.of(context).cardColor,
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                _fontSizeLabels[_fontSize] ?? 'Medium',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
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
            divisions: 7,
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
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ),
              Text(
                'Large',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
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
            color: Theme.of(context).cardColor,
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                languageProvider.isSesotho
                    ? 'Ena ke tsela eo mongolo oa hau o tla sheba boholo bo khethiloeng.'
                    : 'This is how your text will look with the selected font size.',
                style: TextStyle(
                  fontSize: 14 * _fontSize,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
            color: Theme.of(context).cardColor,
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
                languageProvider.isSesotho ? 'Ponelopele ea app' : 'App Preview',
                style: TextStyle(
                  fontSize: 18 * _fontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.isSesotho
                    ? 'Ona ke mohlala o bontšang hore na sebopeho sa app se tla shebahala joang.'
                    : 'This is an example showing what the app interface will look like.',
                style: TextStyle(
                  fontSize: 14 * _fontSize,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
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