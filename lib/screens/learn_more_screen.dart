import 'package:flutter/material.dart';
import 'login_screen.dart';

class LearnMoreScreen extends StatelessWidget {
  const LearnMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5E6),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Hero Section
            SliverToBoxAdapter(
              child: _buildHeroSection(context),
            ),

            // How It Works Section
            SliverToBoxAdapter(
              child: _buildHowItWorksSection(),
            ),

            // Contributors Benefits
            SliverToBoxAdapter(
              child: _buildBenefitsSection(
                title: 'Got Materials to Share?',
                items: [
                  {'icon': Icons.delete, 'title': 'Clear clutter'},
                  {'icon': Icons.palette, 'title': 'Support artisans'},
                  {'icon': Icons.recycling, 'title': 'Reduce waste'},
                  {'icon': Icons.groups, 'title': 'Build community'},
                  {'icon': Icons.analytics, 'title': 'Track impact'},
                ],
              ),
            ),

            // Recipients Benefits
            SliverToBoxAdapter(
              child: _buildBenefitsSection(
                title: 'Find Your Next Masterpiece',
                items: [
                  {'icon': Icons.diamond, 'title': 'Free materials'},
                  {'icon': Icons.savings, 'title': 'Reduce costs'},
                  {'icon': Icons.eco, 'title': 'Create sustainably'},
                  {'icon': Icons.connect_without_contact, 'title': 'Connect'},
                  {'icon': Icons.brush, 'title': 'Showcase work'},
                ],
              ),
            ),

            // Stats Section
            SliverToBoxAdapter(
              child: _buildStatsSection(),
            ),

            // Safety Section
            SliverToBoxAdapter(
              child: _buildSafetySection(),
            ),

            // CTA Section
            SliverToBoxAdapter(
              child: _buildCTASection(context),
            ),

            // Footer
            SliverToBoxAdapter(
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    'Turning Trash Into Treasure, Together',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width > 600 ? 36 : 28,
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
                      fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 16,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'How Junk & Gems Works',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStepCard(Icons.photo_camera, '1', 'List Materials', 'Photograph and list materials you no longer need with location details.')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStepCard(Icons.search, '2', 'Browse Treasures', 'Explore materials listed by community members using smart filters.')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStepCard(Icons.handshake, '3', 'Arrange Pickup', 'Connect with contributors for convenient pickup arrangements.')),
                  ],
                );
              } else if (constraints.maxWidth > 600) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStepCard(Icons.photo_camera, '1', 'List Materials', 'Photograph and list materials you no longer need with location details.')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStepCard(Icons.search, '2', 'Browse Treasures', 'Explore materials listed by community members using smart filters.')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStepCard(Icons.handshake, '3', 'Arrange Pickup', 'Connect with contributors for convenient pickup arrangements.'),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildStepCard(Icons.photo_camera, '1', 'List Materials', 'Photograph and list materials you no longer need with location details.'),
                    const SizedBox(height: 16),
                    _buildStepCard(Icons.search, '2', 'Browse Treasures', 'Explore materials listed by community members using smart filters.'),
                    const SizedBox(height: 16),
                    _buildStepCard(Icons.handshake, '3', 'Arrange Pickup', 'Connect with contributors for convenient pickup arrangements.'),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(IconData icon, String number, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFBEC092).withOpacity(0.3),
                      const Color(0xFF88844D).withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: const Color(0xFF88844D)),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF88844D).withOpacity(0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection({required String title, required List<Map<String, dynamic>> items}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              if (constraints.maxWidth > 900) {
                crossAxisCount = 5;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildBenefitCard(
                    items[index]['icon'] as IconData,
                    items[index]['title'] as String,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBEC092).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFBEC092).withOpacity(0.2),
                  const Color(0xFF88844D).withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: const Color(0xFF88844D)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF88844D), Color(0xFFBEC092)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Join Our Sustainable Movement',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('150+', 'tons saved'),
                    _buildStatDivider(),
                    _buildStatItem('500+', 'exchanges'),
                    _buildStatDivider(),
                    _buildStatItem('200+', 'artisans'),
                    _buildStatDivider(),
                    _buildStatItem('50+', 'communities'),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('150+', 'tons saved')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatItem('500+', 'exchanges')),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('200+', 'artisans')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatItem('50+', 'communities')),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildSafetySection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Safe & Respectful Exchanges',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSafetyColumn('Safety Tips', _getSafetyTips())),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSafetyColumn('Community Rules', _getCommunityRules())),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildSafetyColumn('Safety Tips', _getSafetyTips()),
                    const SizedBox(height: 32),
                    _buildSafetyColumn('Community Rules', _getCommunityRules()),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSafetyTips() {
    return [
      {'icon': Icons.location_on, 'title': 'Meet in public', 'text': 'Choose well-lit, public locations'},
      {'icon': Icons.group, 'title': 'Bring a friend', 'text': 'Have someone accompany you'},
      {'icon': Icons.visibility, 'title': 'Inspect items', 'text': 'Check materials before accepting'},
      {'icon': Icons.security, 'title': 'Trust instincts', 'text': 'Cancel if something feels off'},
    ];
  }

  List<Map<String, dynamic>> _getCommunityRules() {
    return [
      {'icon': Icons.verified, 'title': 'Be honest', 'text': 'Describe materials accurately'},
      {'icon': Icons.chat, 'title': 'Communicate clearly', 'text': 'Be prompt and responsive'},
      {'icon': Icons.schedule, 'title': 'Respect time', 'text': 'Arrive on time for meetups'},
      {'icon': Icons.dangerous, 'title': 'No hazardous items', 'text': 'Do not list unsafe materials'},
    ];
  }

  Widget _buildSafetyColumn(String title, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  title == 'Safety Tips' ? Icons.security : Icons.rule,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSafetyItem(
              item['icon'] as IconData,
              item['title'] as String,
              item['text'] as String,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSafetyItem(IconData icon, String title, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFBEC092).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF88844D)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFBEC092).withOpacity(0.2),
            const Color(0xFF88844D).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBEC092).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.recycling,
            size: 60,
            color: Color(0xFF88844D),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ready to Make a Difference?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Join thousands of community members making sustainable choices every day',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 22),
              label: const Text(
                'Join the Movement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: const Color(0xFF88844D).withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 40, height: 40),
              const SizedBox(width: 12),
              const Text(
                'Junk & Gems',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF88844D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Turning Trash Into Treasure, Together',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.email),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.share),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '© 2025 Junk & Gems. All rights reserved.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFBEC092).withOpacity(0.3),
            const Color(0xFF88844D).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 22,
        color: const Color(0xFF88844D),
      ),
    );
  }
}