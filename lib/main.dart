import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/providers/language_provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';
import 'package:junk_and_gems/providers/cart_provider.dart';
import 'package:junk_and_gems/screens/onboarding_screen.dart';
import 'package:junk_and_gems/screens/dashboard_screen.dart';
import 'package:junk_and_gems/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  await NotificationService.initializeLocalNotifications();
  print('Local notifications initialized');

  // Check if user is logged in and start notifications
  await _initializeNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // AuthProvider is created but NOT initialized here
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeNotifications() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    if (token != null && userId != null) {
      await NotificationService.scheduleDailyTip(
        hour: 10,
        minute: 0,
        enabled: true,
      );
      print('Daily tips scheduled for 10:00 AM');

      NotificationService.startPeriodicSync(userId);
      print('Notification sync started for user: $userId');

      await NotificationService.syncAndShowLocalNotifications(userId);
      print('Initial notification sync completed');
    } else {
      print('ℹ️ User not logged in, notifications will start after login');
    }
  } catch (e) {
    print('Error initializing notifications: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize AuthProvider AFTER widget tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      _syncNotificationsOnResume();
    }
  }

  /// Initialize AuthProvider and check for pending notifications
  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('Initializing app...');
    
    // Initialize auth (loads from storage + refreshes from server)
    await authProvider.initialize();
    
    // Check for pending notification actions
    await _checkPendingNotificationActions();
    
    print('App initialization complete');
  }

  Future<void> _checkPendingNotificationActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = prefs.getString('pending_notification_action');

      if (payload != null && mounted) {
        await prefs.remove('pending_notification_action');

        final parts = payload.split(':');
        final type = parts[0];
        final id = parts.length > 1 ? parts[1] : null;

        print('Handling notification tap: $type, id: $id');

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        
        switch (type) {
          case 'new_user':
            print('Navigate to user profile: $id');
            break;
          
          case 'new_material':
            print('Navigate to material: $id');
            break;
          
          case 'new_product':
            print('Navigate to product: $id');
            break;
          
          case 'daily_tip':
            print('Daily tip notification opened');
            break;
          
          default:
            print('Unknown notification type: $type');
        }
      }
    } catch (e) {
      print('Error checking pending notifications: $e');
    }
  }

  Future<void> _syncNotificationsOnResume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null) {
        await NotificationService.syncAndShowLocalNotifications(userId);
        print('Notifications synced on app resume');
      }
    } catch (e) {
      print('Error syncing on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: 'Junk and Gems',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          locale: Locale(languageProvider.isSesotho ? 'st' : 'en'),
          // Use home with custom builder to check auth state
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              // Show loading while initializing
              if (!authProvider.isInitialized) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBEC092).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF88844D),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // If authenticated, go to dashboard
              if (authProvider.isAuthenticated && authProvider.user != null) {
                return DashboardScreen(
                  userName: authProvider.user!.name,
                  userId: authProvider.user!.id.toString(),
                );
              }

              // Otherwise show onboarding/login
              return const OnboardingScreen();
            },
          ),
        );
      },
    );
  }
}