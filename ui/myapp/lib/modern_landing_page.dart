import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'app_theme.dart';

/// Modern CampusConnect Landing Page
/// Features: Hero section, marquee feature cards, animations, responsive layout
class ModernLandingPage extends StatefulWidget {
  const ModernLandingPage({super.key});

  @override
  State<ModernLandingPage> createState() => _ModernLandingPageState();
}

class _ModernLandingPageState extends State<ModernLandingPage>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _blobController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Hero animations
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );

    _heroSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
        );

    // Blob animation
    _blobController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Start animations
    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Animated background blobs
            _buildAnimatedBackground(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top navigation
                  TopNav(),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Hero section
                          LandingHero(
                            heroFadeAnimation: _heroFadeAnimation,
                            heroSlideAnimation: _heroSlideAnimation,
                            isDesktop: isDesktop,
                            isLoading: _isLoading,
                            onGetStarted: () async {
                              setState(() => _isLoading = true);
                              await Future.delayed(
                                const Duration(milliseconds: 600),
                              );
                              if (mounted) {
                                Navigator.pushNamed(context, '/loginSelection');
                                setState(() => _isLoading = false);
                              }
                            },
                          ),

                          SizedBox(height: AppTheme.spacing6),

                          // Feature marquee section
                          FeatureMarqueeSection(isDesktop: isDesktop),

                          SizedBox(height: AppTheme.spacing6),

                          // Footer
                          Footer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, child) {
        return Stack(
          children: [
            // Subtle gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    AppTheme.backgroundGradient,
                    Colors.white,
                  ],
                ),
              ),
            ),
            // Blob 1 - Cyan
            Positioned(
              top: 100 + math.sin(_blobController.value * 2 * math.pi) * 50,
              right: 100 + math.cos(_blobController.value * 2 * math.pi) * 30,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accent.withOpacity(0.15),
                      AppTheme.accent.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Blob 2 - Purple
            Positioned(
              bottom: 150 + math.cos(_blobController.value * 2 * math.pi) * 40,
              left: 50 + math.sin(_blobController.value * 2 * math.pi) * 20,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentPurple.withOpacity(0.12),
                      AppTheme.accentPurple.withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Blob 3 - Green
            Positioned(
              top: 400 + math.sin(_blobController.value * 2 * math.pi + 2) * 30,
              left: 200 + math.cos(_blobController.value * 2 * math.pi) * 40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentGreen.withOpacity(0.1),
                      AppTheme.accentGreen.withOpacity(0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Top Navigation Bar Widget
class TopNav extends StatelessWidget {
  const TopNav({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 500;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing2,
      ),
      child: Row(
        children: [
          // Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.school,
                  color: AppTheme.white,
                  size: 24,
                ),
              ),
              if (!isSmallScreen) ...[
                SizedBox(width: AppTheme.spacing1),
                Text(
                  'CampusConnect',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          // Login/Signup actions
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/loginSelection'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
              minimumSize: const Size(48, 48),
            ),
            child: Text(
              'Login',
              style: GoogleFonts.inter(
                color: AppTheme.neutral,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 4 : AppTheme.spacing1),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/loginSelection'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accent,
              side: const BorderSide(color: AppTheme.accent),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 16,
                vertical: isSmallScreen ? 8 : 12,
              ),
              minimumSize: const Size(48, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            child: Text(
              'Sign Up',
              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Landing Hero Section Widget
class LandingHero extends StatelessWidget {
  final Animation<double> heroFadeAnimation;
  final Animation<Offset> heroSlideAnimation;
  final bool isDesktop;
  final bool isLoading;
  final VoidCallback onGetStarted;

  const LandingHero({
    super.key,
    required this.heroFadeAnimation,
    required this.heroSlideAnimation,
    required this.isDesktop,
    required this.isLoading,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacing6 : AppTheme.spacing3,
        vertical: AppTheme.spacing4,
      ),
      child: FadeTransition(
        opacity: heroFadeAnimation,
        child: SlideTransition(
          position: heroSlideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lottie animation
              SizedBox(
                height: isDesktop ? 120 : 100,
                child: Lottie.network(
                  'https://lottie.host/4c3e0def-524b-44be-a0c8-9c5c9c6c2a5e/gvLBDlBHPa.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.school,
                      size: 80,
                      color: AppTheme.accent,
                    );
                  },
                ),
              ),
              SizedBox(height: AppTheme.spacing3),

              // Headline
              Text(
                'CampusConnect',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 48 : 36,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                  height: 1.2,
                ),
              ),
              SizedBox(height: AppTheme.spacing1),
              Text(
                'Your Smart College Companion',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
              SizedBox(height: AppTheme.spacing2),

              // Subheadline
              Text(
                'Attendance, Labs, Timetables & Exams — all in one place',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: AppTheme.subheadlineSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.neutral,
                  height: 1.5,
                ),
              ),
              SizedBox(height: AppTheme.spacing4),

              // CTA button
              CTAGroup(
                isDesktop: isDesktop,
                isLoading: isLoading,
                onGetStarted: onGetStarted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CTA Button Group Widget
class CTAGroup extends StatelessWidget {
  final bool isDesktop;
  final bool isLoading;
  final VoidCallback onGetStarted;

  const CTAGroup({
    super.key,
    required this.isDesktop,
    required this.isLoading,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedScale(
        scale: isLoading ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ElevatedButton(
          onPressed: onGetStarted,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: AppTheme.white,
            elevation: 4,
            shadowColor: AppTheme.accent.withOpacity(0.3),
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing2,
            ),
            minimumSize: const Size(160, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.white,
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(Icons.rocket_launch, size: 20),
              SizedBox(width: AppTheme.spacing1),
              Text(
                'Get Started',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature Marquee Section Widget - All cards scroll horizontally in one row
class FeatureMarqueeSection extends StatefulWidget {
  final bool isDesktop;

  const FeatureMarqueeSection({super.key, required this.isDesktop});

  @override
  State<FeatureMarqueeSection> createState() => _FeatureMarqueeSectionState();
}

class _FeatureMarqueeSectionState extends State<FeatureMarqueeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.check_circle_outline,
      'title': 'Smart Attendance Management',
      'description':
          'Faculty mark attendance quickly; students track their records anytime.',
    },
    {
      'icon': Icons.laptop_chromebook,
      'title': 'Real-Time Lab Occupancy',
      'description': 'Shows which labs are in use and which are free.',
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Automatic Timetable Management',
      'description': 'Displays updated schedules for faculty and students.',
    },
    {
      'icon': Icons.event_seat,
      'title': 'Exam Seating Arrangement',
      'description':
          'Students instantly check their exam hall and seat number.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? AppTheme.spacing6 : AppTheme.spacing3,
      ),
      child: Column(
        children: [
          // Section Header
          Text(
            'What CampusConnect Does',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: widget.isDesktop ? 32 : 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
            ),
          ),
          SizedBox(height: AppTheme.spacing4),

          // Single horizontal scrolling row
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth * 0.75;
                    final spacing = 20.0;
                    final totalWidth =
                        (_features.length * (cardWidth + spacing));
                    final offset = _animation.value * totalWidth;

                    return ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        child: Transform.translate(
                          offset: Offset(-offset, 0),
                          child: Row(
                            children: [
                              ..._features.map(
                                (feature) => Padding(
                                  padding: EdgeInsets.only(right: spacing),
                                  child: SizedBox(
                                    width: cardWidth,
                                    child: _buildCard(
                                      feature['icon'] as IconData,
                                      feature['title'] as String,
                                      feature['description'] as String,
                                    ),
                                  ),
                                ),
                              ),
                              ..._features.map(
                                (feature) => Padding(
                                  padding: EdgeInsets.only(right: spacing),
                                  child: SizedBox(
                                    width: cardWidth,
                                    child: _buildCard(
                                      feature['icon'] as IconData,
                                      feature['title'] as String,
                                      feature['description'] as String,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String description) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppTheme.cardBackground],
        ),
        border: Border.all(color: AppTheme.borderLight, width: 1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      padding: EdgeInsets.all(AppTheme.spacing2), // Reduced padding
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.accent.withOpacity(0.9), AppTheme.accent],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28), // Smaller icon
          ),
          SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Don't expand vertically
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16, // Smaller font
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4), // Reduced spacing
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13, // Smaller font
                    color: AppTheme.neutralLight,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer Widget
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.infoBackground,
        border: Border(top: BorderSide(color: AppTheme.borderLight, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'About',
                  style: GoogleFonts.inter(color: AppTheme.neutral),
                ),
              ),
              Text('•', style: TextStyle(color: AppTheme.neutral)),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Features',
                  style: GoogleFonts.inter(color: AppTheme.neutral),
                ),
              ),
              Text('•', style: TextStyle(color: AppTheme.neutral)),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Contact',
                  style: GoogleFonts.inter(color: AppTheme.neutral),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            '© 2025 CampusConnect. All Rights Reserved.',
            style: GoogleFonts.inter(
              fontSize: AppTheme.captionSize,
              color: AppTheme.neutralLight,
            ),
          ),
        ],
      ),
    );
  }
}
