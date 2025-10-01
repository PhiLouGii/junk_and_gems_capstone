import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/language_provider.dart';
import 'package:junk_and_gems/screens/onboarding_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Junk and Gems',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          // Change home screen text depending on language
          home: const OnboardingScreen(),
          debugShowCheckedModeBanner: false,
          locale: Locale(languageProvider.isSesotho ? 'st' : 'en'),
        );
      },
    );
  }
}
