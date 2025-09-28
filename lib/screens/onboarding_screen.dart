import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/welcome_screen.dart'; 

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea (
          child: Padding(
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


                    // Subtitle
                    const Text(
                      'Turn your junk into treasure, together',
                      style: TextStyle(
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
                    // Get Started Button - UPDATED TO NAVIGATE
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to WelcomeScreen
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
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
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
                          // Navigate to More information
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF88844D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Learn More',
                          style: TextStyle(
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
      ),
      ),
    );
  }
}