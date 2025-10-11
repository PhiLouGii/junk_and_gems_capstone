import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import your existing login screen

class LearnMoreScreen extends StatelessWidget {
  const LearnMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F5E6),
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverAppBar(
            expandedHeight: 400,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background Image with Gradient
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/background.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Turning Trash Into Treasure, Together',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A community where waste finds new purpose and creativity meets sustainability.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // How It Works Section
                  _buildSection(
                    title: 'How Junk & Gems Works',
                    children: [
                      const SizedBox(height: 32),
                      _buildThreeColumnGrid(
                        children: [
                          _buildFeatureCard(
                            icon: Icons.photo_camera,
                            title: 'List Unwanted Materials',
                            description: 'Easily photograph and list materials you no longer need. Provide a brief description and location for potential recipients.',
                          ),
                          _buildFeatureCard(
                            icon: Icons.search,
                            title: 'Browse Available Treasures',
                            description: 'Explore a diverse range of materials listed by other community members. Use filters to find exactly what you need for your next project.',
                          ),
                          _buildFeatureCard(
                            icon: Icons.handshake,
                            title: 'Arrange Pickup',
                            description: 'Once you\'ve found a match, connect with the contributor to arrange a convenient pickup time and location.',
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // Benefits for Contributors Section
                  _buildSection(
                    title: 'Got Materials to Share?',
                    children: [
                      const SizedBox(height: 32),
                      _buildFiveColumnGrid(
                        children: [
                          _buildBenefitCard(
                            icon: Icons.delete,
                            title: 'Clear clutter responsibly',
                          ),
                          _buildBenefitCard(
                            icon: Icons.palette,
                            title: 'Support local artisans',
                          ),
                          _buildBenefitCard(
                            icon: Icons.recycling,
                            title: 'Reduce landfill waste',
                          ),
                          _buildBenefitCard(
                            icon: Icons.groups,
                            title: 'Build community',
                          ),
                          _buildBenefitCard(
                            icon: Icons.analytics,
                            title: 'Track environmental impact',
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // Benefits for Recipients Section
                  _buildSection(
                    title: 'Find Your Next Masterpiece',
                    children: [
                      const SizedBox(height: 32),
                      _buildFiveColumnGrid(
                        children: [
                          _buildBenefitCard(
                            icon: Icons.diamond,
                            title: 'Discover free materials',
                          ),
                          _buildBenefitCard(
                            icon: Icons.savings,
                            title: 'Reduce project costs',
                          ),
                          _buildBenefitCard(
                            icon: Icons.eco,
                            title: 'Create sustainably',
                          ),
                          _buildBenefitCard(
                            icon: Icons.connect_without_contact,
                            title: 'Connect with sources',
                          ),
                          _buildBenefitCard(
                            icon: Icons.brush,
                            title: 'Showcase your work',
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // Stats Section
                  _buildSection(
                    title: 'Join Our Sustainable Movement',
                    children: [
                      const SizedBox(height: 32),
                      _buildFourColumnGrid(
                        children: [
                          _buildStatCard(number: '150+', label: 'tons saved'),
                          _buildStatCard(number: '500+', label: 'exchanges'),
                          _buildStatCard(number: '200+', label: 'artisans'),
                          _buildStatCard(number: '50+', label: 'communities'),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // Safety & Rules Section
                  _buildSection(
                    title: 'Safe & Respectful Exchanges',
                    children: [
                      const SizedBox(height: 32),
                      _buildSafetyGrid(
                        safetyTips: [
                          _buildSafetyItem(
                            icon: Icons.location_on,
                            title: 'Meet in public:',
                            text: 'Choose a well-lit, public location.',
                          ),
                          _buildSafetyItem(
                            icon: Icons.group,
                            title: 'Bring a friend:',
                            text: 'If possible, have someone with you.',
                          ),
                          _buildSafetyItem(
                            icon: Icons.visibility,
                            title: 'Inspect items:',
                            text: 'Check materials before accepting them.',
                          ),
                          _buildSafetyItem(
                            icon: Icons.security,
                            title: 'Trust instincts:',
                            text: 'Cancel if something feels off.',
                          ),
                        ],
                        communityRules: [
                          _buildSafetyItem(
                            icon: Icons.verified,
                            title: 'Be honest:',
                            text: 'Accurately describe materials.',
                          ),
                          _buildSafetyItem(
                            icon: Icons.chat,
                            title: 'Communicate clearly:',
                            text: 'Be prompt and responsive.',
                          ),
                          _buildSafetyItem(
                            icon: Icons.schedule,
                            title: 'Respect time:',
                            text: 'Arrive on time for meetups.',
                          ),
                          _buildSafetyItem(
                            icon: Icons.dangerous,
                            title: 'No hazardous materials:',
                            text: 'Do not list unsafe items.',
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // CTA Section
                  _buildCTASection(context),

                  const SizedBox(height: 60),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
          textAlign: TextAlign.center,
        ),
        ...children,
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF88844D).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Color(0xFF88844D),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF88844D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Color(0xFF88844D),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String number, required String label}) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF88844D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF88844D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Color(0xFF88844D),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Login Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(), // Your existing login screen
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF88844D),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: Color(0xFF88844D).withOpacity(0.3),
              ),
              child: Text(
                'Join the Movement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Junk & Gems',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF88844D),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Turning Trash Into Treasure, Together',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 Junk & Gems. All rights reserved.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook),
              SizedBox(width: 16),
              _buildSocialIcon(Icons.email),
              SizedBox(width: 16),
              _buildSocialIcon(Icons.share),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFF88844D).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: Color(0xFF88844D),
      ),
    );
  }

  // Layout helpers for different screen sizes
  Widget _buildThreeColumnGrid({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map((child) => Expanded(child: child))
                .toList(),
          );
        } else {
          return Column(
            children: children,
          );
        }
      },
    );
  }

  Widget _buildFourColumnGrid({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children: children
                .map((child) => Expanded(child: child))
                .toList(),
          );
        } else {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: children,
          );
        }
      },
    );
  }

  Widget _buildFiveColumnGrid({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children: children
                .map((child) => Expanded(child: child))
                .toList(),
          );
        } else {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: children,
          );
        }
      },
    );
  }

  Widget _buildSafetyGrid({
    required List<Widget> safetyTips,
    required List<Widget> communityRules,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety Tips',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...safetyTips,
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Rules',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...communityRules,
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety Tips',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...safetyTips,
                ],
              ),
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community Rules',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...communityRules,
                ],
              ),
            ],
          );
        }
      },
    );
  }
}