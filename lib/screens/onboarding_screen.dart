import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/learn_more_screen.dart';
import 'package:junk_and_gems/screens/welcome_screen.dart'; 
import 'package:junk_and_gems/utils/app_localizations.dart';
import 'package:junk_and_gems/components/language_toggle_button.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/language_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with Consumer to react to language changes
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final loc = context.loc;
        
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFBEC092),
                  Color(0xFFBEC092),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/onboarding_image.png',
                              width: 450,
                              height: 450,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 40),

                            // Title
                            const Text(
                              'Junk & Gems',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Subtitle - now translatable
                            Text(
                              loc.onboardingSubtitle,
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        // Buttons Section
                        Column(
                          children: [
                            // Get Started Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WelcomeScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF88844D),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  loc.getStarted,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Learn More Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LearnMoreScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF88844D),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  loc.learnMore,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Language toggle button (globe icon) in top-right corner
                  Positioned(
                    top: 16,
                    right: 16,
                    child: LanguageToggleButton(
                      iconColor: Colors.white,
                      backgroundColor: const Color(0xFF88844D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}