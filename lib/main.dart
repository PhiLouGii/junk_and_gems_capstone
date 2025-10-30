import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junk_and_gems/providers/language_provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';
import 'package:junk_and_gems/providers/cart_provider.dart';
import 'package:junk_and_gems/screens/onboarding_screen.dart';
import 'package:junk_and_gems/services/notification_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  await NotificationService.initializeLocalNotifications();
  print('✅ Local notifications initialized');

  // Check if user is logged in and start notifications
  await _initializeNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Initialize notifications for logged-in users
Future<void> _initializeNotifications() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && userId != null) {
      // Schedule daily motivational tips at 10 AM
      await NotificationService.scheduleDailyTip(
        hour: 10,
        minute: 0,
        enabled: true,
      );
      print('✅ Daily tips scheduled for 10:00 AM');

      // Start periodic sync with backend (every 5 minutes)
      NotificationService.startPeriodicSync(userId);
      print('✅ Notification sync started for user: $userId');

      // Do an immediate sync to check for any pending notifications
      await NotificationService.syncAndShowLocalNotifications(userId);
      print('✅ Initial notification sync completed');
    } else {
      print('ℹ️ User not logged in, notifications will start after login');
    }
  } catch (e) {
    print('❌ Error initializing notifications: $e');
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
    
    // Check for pending notification actions after app loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingNotificationActions();
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
    
    // When app comes to foreground, sync notifications
    if (state == AppLifecycleState.resumed) {
      _syncNotificationsOnResume();
    }
  }

  /// Check if user tapped a notification and handle navigation
  Future<void> _checkPendingNotificationActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = prefs.getString('pending_notification_action');

      if (payload != null && mounted) {
        // Clear the stored action
        await prefs.remove('pending_notification_action');

        // Parse payload (format: "type:id")
        final parts = payload.split(':');
        final type = parts[0];
        final id = parts.length > 1 ? parts[1] : null;

        print('📱 Handling notification tap: $type, id: $id');

        // Add a small delay to ensure navigation is ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Handle navigation based on type
        if (!mounted) return;
        
        switch (type) {
          case 'new_user':
            // Navigate to user profile
            // Navigator.pushNamed(context, '/profile', arguments: id);
            print('Navigate to user profile: $id');
            break;
          
          case 'new_material':
            // Navigate to material details
            // Navigator.pushNamed(context, '/material', arguments: id);
            print('Navigate to material: $id');
            break;
          
          case 'new_product':
            // Navigate to product details
            // Navigator.pushNamed(context, '/product', arguments: id);
            print('Navigate to product: $id');
            break;
          
          case 'daily_tip':
            // Maybe navigate to tips screen or just open app
            print('Daily tip notification opened');
            break;
          
          default:
            print('Unknown notification type: $type');
        }
      }
    } catch (e) {
      print('❌ Error checking pending notifications: $e');
    }
  }

  /// Sync notifications when app resumes
  Future<void> _syncNotificationsOnResume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null) {
        await NotificationService.syncAndShowLocalNotifications(userId);
        print('✅ Notifications synced on app resume');
      }
    } catch (e) {
      print('❌ Error syncing on resume: $e');
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
          home: const OnboardingScreen(),
          debugShowCheckedModeBanner: false,
          locale: Locale(languageProvider.isSesotho ? 'st' : 'en'),
        );
      },
    );
  }
}