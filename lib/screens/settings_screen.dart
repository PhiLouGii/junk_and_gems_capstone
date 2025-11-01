import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/payments_earnings_screen.dart';
import 'package:junk_and_gems/services/notification_service.dart';
import 'package:junk_and_gems/screens/login_screen.dart';
import 'package:junk_and_gems/providers/language_provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/screens/legal_webview_screen.dart';
import 'package:junk_and_gems/utils/legal_content.dart';
import 'package:junk_and_gems/utils/app_localizations.dart';
import 'package:junk_and_gems/components/language_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
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
          loc.settings,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          // Add language toggle button in app bar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: LanguageToggleButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, loc.quickSettings),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.notifications_outlined, loc.notifications),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return _buildSettingItem(
                  context, 
                  Icons.dark_mode_outlined, 
                  loc.darkMode, 
                  hasToggle: true,
                  switchValue: themeProvider.isDarkMode,
                  onSwitchChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, loc.preferences),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.payment_outlined, loc.paymentsEarnings, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentsEarningsScreen()),
              );
            }),
            _buildSettingItem(context, Icons.settings_applications_outlined, loc.appPreferences, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppPreferencesScreen()),
              );
            }),
            const SizedBox(height: 32),
            _buildSectionHeader(context, loc.support),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.help_outline, loc.helpSupport),
            _buildSettingItem(context, Icons.info_outline, loc.legalInfo),
            const SizedBox(height: 32),
            _buildSectionHeader(context, loc.account),
            const SizedBox(height: 16),
            _buildSettingItem(context, Icons.logout_outlined, loc.signOut, isDestructive: true),
            _buildSettingItem(context, Icons.delete_outline, loc.deleteAccount, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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

  Widget _buildSettingItem(BuildContext context, IconData icon, String title,
      {bool hasToggle = false, 
       bool isDestructive = false, 
       VoidCallback? onTap,
       bool? switchValue,
       Function(bool)? onSwitchChanged}) {
    final loc = context.loc;
    
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
          if (title == loc.signOut) {
            _showSignOutDialog(context);
          } else if (title == loc.deleteAccount) {
            _showDeleteAccountDialog(context);
          } else if (title == loc.legalInfo) {
            _launchLegalInfo(context);
          }
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final loc = context.loc;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          loc.signOut, 
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color, 
            fontWeight: FontWeight.bold
          )
        ),
        content: Text(
          loc.signOutConfirm, 
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(
              loc.cancel, 
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            )
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF88844D),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Signing out...',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              try {
                print('🔒 Starting logout process...');
                
                await NotificationService.cancelAllLocalNotifications();
                print('✅ Notifications cancelled');

                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                await prefs.remove('token');
                await prefs.remove('user_data');
                await prefs.remove('userId');
                await prefs.remove('userName');
                await prefs.remove('userEmail');
                await prefs.setBool('isLoggedIn', false);
                print('✅ User data cleared');

                final authProvider = Provider.of<AuthProvider>(
                  context, 
                  listen: false
                );
                await authProvider.initialize();
                print('✅ AuthProvider cleared');

                print('✅ Logout successful');

                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                print('❌ Logout error: $e');
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }, 
            child: Text(
              loc.signOut, 
              style: const TextStyle(
                color: Colors.red, 
                fontWeight: FontWeight.bold
              )
            )
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final loc = context.loc;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(loc.deleteAccount, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(loc.deleteAccountWarning, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(loc.cancel, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))
          ),
          TextButton(
            onPressed: () {}, 
            child: Text(loc.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _launchLegalInfo(BuildContext context) {
    final loc = context.loc;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalWebViewScreen(
          title: loc.legalInfo,
          htmlContent: LegalContent.legalInfo,
        ),
      ),
    );
  }
}

// AppPreferencesScreen remains the same
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
    final loc = context.loc;
    
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
          loc.appPreferences,
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
            _buildSectionHeader(context, loc.language.toUpperCase()),
            const SizedBox(height: 16),
            _buildLanguageToggle(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, loc.display),
            const SizedBox(height: 16),
            _buildFontSizeSlider(context),
            const SizedBox(height: 16),
            _buildFontSizePreview(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, loc.preview.toUpperCase()),
            const SizedBox(height: 16),
            _buildPreviewCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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

  Widget _buildLanguageToggle(BuildContext context) {
    final loc = context.loc;
    
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
              loc.appLanguage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              languageProvider.isSesotho ? loc.sesotho : loc.english,
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

  Widget _buildFontSizeSlider(BuildContext context) {
    final loc = context.loc;
    
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
                loc.fontSize,
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
                loc.fontSizeSmall,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ),
              Text(
                loc.fontSizeLarge,
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

  Widget _buildFontSizePreview(BuildContext context) {
    final loc = context.loc;
    
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
                loc.preview,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.previewText,
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

  Widget _buildPreviewCard(BuildContext context) {
    final loc = context.loc;
    
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
                loc.appPreview,
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
                      loc.donateMaterials,
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