import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Login Selection Page - choose Student / Staff / Management login flows
class LoginSelectionPage extends StatefulWidget {
  const LoginSelectionPage({super.key});

  @override
  State<LoginSelectionPage> createState() => _LoginSelectionPageState();
}

class _LoginSelectionPageState extends State<LoginSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF222831)),
        title: const Text(
          'Welcome Back',
          style: TextStyle(
            color: Color(0xFF222831),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF5F5F5),
                      Colors.white,
                    ],
                    stops: [
                      0.0,
                      math.sin(_backgroundController.value * 2 * math.pi) *
                              0.2 +
                          0.5,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating accent blobs
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    math.cos(_backgroundController.value * 2 * math.pi) * 30,
                    math.sin(_backgroundController.value * 2 * math.pi) * 30,
                  ),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00ADB5).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -150,
            left: -150,
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    math.sin(_backgroundController.value * 2 * math.pi) * 40,
                    math.cos(_backgroundController.value * 2 * math.pi) * 40,
                  ),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00ADB5).withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final bool isLarge = width > 900;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Title section
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00ADB5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF00ADB5).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'CampusConnect',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF00ADB5),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Choose Your Portal',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222831),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Select your role to access personalized features',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF222831).withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Cards: use Column or Row depending on width
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: isLarge
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildGlassCard(
                                      context,
                                      0,
                                      Icons.school_rounded,
                                      'Student Portal',
                                      'Access attendance, timetable & grades',
                                      '/studentLogin',
                                      const Color(0xFF00ADB5),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildGlassCard(
                                      context,
                                      1,
                                      Icons.business_center_rounded,
                                      'Faculty Portal',
                                      'Manage classes, students & resources',
                                      '/staffLogin',
                                      const Color(0xFF00C9A7),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildGlassCard(
                                      context,
                                      2,
                                      Icons.admin_panel_settings_rounded,
                                      'Admin Portal',
                                      'System control & analytics dashboard',
                                      '/managementLogin',
                                      const Color(0xFF845EC2),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildGlassCard(
                                    context,
                                    0,
                                    Icons.school_rounded,
                                    'Student Portal',
                                    'Access attendance, timetable & grades',
                                    '/studentLogin',
                                    const Color(0xFF00ADB5),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildGlassCard(
                                    context,
                                    1,
                                    Icons.business_center_rounded,
                                    'Faculty Portal',
                                    'Manage classes, students & resources',
                                    '/staffLogin',
                                    const Color(0xFF00C9A7),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildGlassCard(
                                    context,
                                    2,
                                    Icons.admin_panel_settings_rounded,
                                    'Admin Portal',
                                    'System control & analytics dashboard',
                                    '/managementLogin',
                                    const Color(0xFF845EC2),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 48),

                      // Footer note
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00ADB5).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: const Color(0xFF222831).withOpacity(0.5),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Frontend demo - No authentication performed',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color(
                                    0xFF222831,
                                  ).withOpacity(0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(
    BuildContext context,
    int index,
    IconData icon,
    String title,
    String subtitle,
    String routeName,
    Color accentColor,
  ) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _hoveredIndex == index ? -8.0 : 0.0),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, routeName),
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, const Color(0xFFFAFAFA)],
              ),
              border: Border.all(
                color: _hoveredIndex == index
                    ? accentColor.withOpacity(0.6)
                    : const Color(0xFFE0E0E0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hoveredIndex == index
                      ? accentColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: _hoveredIndex == index ? 24 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon container with gradient
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withOpacity(0.8),
                                accentColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 32, color: Colors.white),
                        ),

                        const Spacer(),

                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222831),
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF222831).withOpacity(0.6),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Arrow indicator
                        Row(
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              transform: Matrix4.identity()
                                ..translate(
                                  _hoveredIndex == index ? 4.0 : 0.0,
                                  0.0,
                                ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shine effect on hover
                  if (_hoveredIndex == index)
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accentColor.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
