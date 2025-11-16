// Replace your entire spotlight_tutorial.dart with this simple version:

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleTutorial extends StatefulWidget {
  final VoidCallback onComplete;

  const SimpleTutorial({
    super.key,
    required this.onComplete,
  });

  @override
  State<SimpleTutorial> createState() => _SimpleTutorialState();
}

class _SimpleTutorialState extends State<SimpleTutorial> {
  int currentStep = 0;
  
  final List<TutorialStep> steps = [
    TutorialStep(
      icon: Icons.diamond,
      title: 'Welcome to Junk & Gems!',
      description: 'Let\'s take a quick tour of the app to help you get started.',
    ),
    TutorialStep(
      icon: Icons.star,
      title: 'Earn Gems',
      description: 'Collect gems by checking in daily, donating materials, or claiming materials. Use gems for discounts on upcycled products!',
    ),
    TutorialStep(
      icon: Icons.inventory_2,
      title: 'Browse Materials',
      description: 'Find recyclable materials donated by others. Tap "Browse" in the bottom menu to explore available materials.',
    ),
    TutorialStep(
      icon: Icons.add_circle_outline,
      title: 'Donate Materials',
      description: 'Have materials to share? Donate them to the community and earn gems while helping others!',
    ),
    TutorialStep(
      icon: Icons.shopping_bag,
      title: 'Shop Marketplace',
      description: 'Buy unique upcycled products or sell your own creations. Tap "Shop" to browse the marketplace.',
    ),
    TutorialStep(
      icon: Icons.notifications,
      title: 'Stay Updated',
      description: 'Check "Alerts" for notifications and messages about your donations, claims, and sales.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStep >= steps.length) {
      return const SizedBox.shrink();
    }

    final step = steps[currentStep];
    
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 20,
              right: 20,
              child: TextButton.icon(
                onPressed: widget.onComplete,
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            
            // Tutorial content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF88844D).withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        step.icon,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        steps.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == currentStep ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == currentStep
                                ? const Color(0xFFBEC092)
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Next button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBEC092),
                          foregroundColor: const Color(0xFF88844D),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          currentStep == steps.length - 1
                              ? 'Get Started!'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }
}

class TutorialStep {
  final IconData icon;
  final String title;
  final String description;

  TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// Also export this for backward compatibility
class SpotlightTutorial extends SimpleTutorial {
  const SpotlightTutorial({
    super.key,
    required super.onComplete,
  });
}

// Update your dashboard_screen.dart _checkFirstTime to:
/*
Future<void> _checkFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  final hasSeenTutorial = prefs.getBool('has_seen_dashboard_tutorial') ?? false;
  
  if (!hasSeenTutorial) {
    // Simple 1 second delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        showTutorial = true;
      });
    }
  }
}
*/

class TutorialTarget extends StatelessWidget {
  final String targetKey;
  final Widget child;

  const TutorialTarget({
    super.key,
    required this.targetKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child; 
  }
}