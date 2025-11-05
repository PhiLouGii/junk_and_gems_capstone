import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpotlightTutorial extends StatefulWidget {
  final VoidCallback onComplete;

  const SpotlightTutorial({
    super.key,
    required this.onComplete,
  });

  @override
  State<SpotlightTutorial> createState() => _SpotlightTutorialState();
}

class _SpotlightTutorialState extends State<SpotlightTutorial> {
  int currentStep = 0;
  
  final List<TutorialStep> steps = [
    TutorialStep(
      targetKey: 'gems_circle',
      title: 'Your Gems',
      description: 'Earn gems by checking in daily, donating materials, or claiming materials. Those gems can be used later for price discounts on upcycled products!',
      position: TutorialPosition.bottom,
    ),
    TutorialStep(
      targetKey: 'nav_browse',
      title: 'Browse Materials',
      description: 'Browse materials here or donate your materials to help the community.',
      position: TutorialPosition.top,
    ),
    TutorialStep(
      targetKey: 'nav_shop',
      title: 'Marketplace',
      description: 'Buy something uniquely designed and upcycled or sell your own creations.',
      position: TutorialPosition.top,
    ),
    TutorialStep(
      targetKey: 'nav_alerts',
      title: 'Notifications',
      description: 'Find notifications and messages here to stay updated.',
      position: TutorialPosition.top,
    ),
    TutorialStep(
      targetKey: 'nav_profile',
      title: 'Your Profile',
      description: 'Your profile and settings are here. Customise your experience!',
      position: TutorialPosition.top,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStep >= steps.length) {
      return const SizedBox.shrink();
    }

    final step = steps[currentStep];
    
    return Stack(
      children: [
        // Dark overlay
        GestureDetector(
          onTap: () {}, // Prevent background interaction
          child: Container(
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        
        // Spotlight hole (transparent circle)
        CustomPaint(
          painter: SpotlightPainter(
            targetKey: step.targetKey,
          ),
          child: Container(),
        ),
        
        // Tutorial card
        _buildTutorialCard(step),
      ],
    );
  }

  Widget _buildTutorialCard(TutorialStep step) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetPosition = _getTargetPosition(step.targetKey);
        
        if (targetPosition == null) {
          // If target not found, show in center
          return Center(
            child: _buildCard(step),
          );
        }

        double top = 0;
        double? bottom;
        
        if (step.position == TutorialPosition.bottom) {
          top = targetPosition.bottom + 20;
        } else {
          bottom = constraints.maxHeight - targetPosition.top + 20;
        }

        return Positioned(
          top: step.position == TutorialPosition.bottom ? top : null,
          bottom: step.position == TutorialPosition.top ? bottom : null,
          left: 20,
          right: 20,
          child: _buildCard(step),
        );
      },
    );
  }

  Widget _buildCard(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88844D).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForStep(step.targetKey),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF88844D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentStep + 1} of ${steps.length}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF88844D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  currentStep == steps.length - 1 ? 'Got it!' : 'Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForStep(String targetKey) {
    switch (targetKey) {
      case 'gems_circle':
        return Icons.diamond;
      case 'nav_browse':
        return Icons.inventory_2;
      case 'nav_shop':
        return Icons.shopping_bag;
      case 'nav_alerts':
        return Icons.notifications;
      case 'nav_profile':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  Rect? _getTargetPosition(String key) {
    final RenderBox? renderBox = _findRenderBox(key);
    if (renderBox == null) return null;
    
    final position = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
  }

  RenderBox? _findRenderBox(String key) {
    try {
      final BuildContext? targetContext = _contextMap[key];
      if (targetContext == null) return null;
      return targetContext.findRenderObject() as RenderBox?;
    } catch (e) {
      return null;
    }
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

  // Global map to store widget keys
  static final Map<String, BuildContext> _contextMap = {};
  
  void registerContext(String key, BuildContext context) {
    _contextMap[key] = context;
  }
  
  void unregisterContext(String key) {
    _contextMap.remove(key);
  }
}

class TutorialStep {
  final String targetKey;
  final String title;
  final String description;
  final TutorialPosition position;

  TutorialStep({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.position,
  });
}

enum TutorialPosition {
  top,
  bottom,
}

class SpotlightPainter extends CustomPainter {
  final String targetKey;

  SpotlightPainter({required this.targetKey});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final targetPosition = _getTargetPosition(targetKey);
    
    if (targetPosition != null) {
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      
      // Create spotlight circle
      final center = Offset(
        targetPosition.left + targetPosition.width / 2,
        targetPosition.top + targetPosition.height / 2,
      );
      
      final radius = (targetPosition.width > targetPosition.height 
          ? targetPosition.width 
          : targetPosition.height) / 2 + 15;
      
      path.addOval(Rect.fromCircle(center: center, radius: radius));
      path.fillType = PathFillType.evenOdd;
      
      canvas.drawPath(path, paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  Rect? _getTargetPosition(String key) {
    final BuildContext? targetContext = _SpotlightTutorialState._contextMap[key];
    if (targetContext == null) return null;
    
    try {
      final RenderBox? renderBox = targetContext.findRenderObject() as RenderBox?;
      if (renderBox == null) return null;
      
      final position = renderBox.localToGlobal(Offset.zero);
      return Rect.fromLTWH(
        position.dx,
        position.dy,
        renderBox.size.width,
        renderBox.size.height,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Helper widget to register context
class TutorialTarget extends StatefulWidget {
  final String targetKey;
  final Widget child;

  TutorialTarget({
    super.key,
    required this.targetKey,
    required this.child,
  });

  @override
  State<TutorialTarget> createState() => _TutorialTargetState();
}

class _TutorialTargetState extends State<TutorialTarget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      _SpotlightTutorialState._contextMap[widget.targetKey] = context;
    });
  }

  @override
  void dispose() {
    _SpotlightTutorialState._contextMap.remove(widget.targetKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _SpotlightTutorialState._contextMap[widget.targetKey] = context;
    });
    return widget.child;
  }
}