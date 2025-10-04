import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/language_provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:junk_and_gems/providers/auth_provider.dart';
import 'package:junk_and_gems/providers/cart_provider.dart';
import 'package:junk_and_gems/screens/onboarding_screen.dart';

void main() {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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