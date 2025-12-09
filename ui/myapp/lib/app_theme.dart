import 'package:flutter/material.dart';

/// Design system constants for CampusConnect
/// Theme colors, typography, and spacing following 8px baseline grid
/// Updated to use white background theme consistently across all pages
class AppTheme {
  // Color Palette - White Theme
  static const Color background = Color(
    0xFFFFFFFF,
  ); // Primary background - white
  static const Color backgroundGradient = Color(
    0xFF12121,
  ); // Subtle gradient accent
  static const Color primaryDark = Color(0xFF222831); // Text and UI elements
  static const Color neutral = Color(0xFF393E46); // Secondary text
  static const Color accent = Color(0xFF00ADB5); // Primary accent (cyan/teal)
  static const Color accentGreen = Color(
    0xFF00C9A7,
  ); // Secondary accent (green)
  static const Color accentPurple = Color(
    0xFF845EC2,
  ); // Tertiary accent (purple)
  static const Color white = Color(0xFFFFFFFF);

  // UI Element Colors
  static const Color cardBackground = Color(0xFFFAFAFA); // Card gradient end
  static const Color borderLight = Color(0xFFE0E0E0); // Default borders
  static const Color infoBackground = Color(
    0xFFF5F5F5,
  ); // Info boxes, footer notes

  // Opacity variations
  static Color accentLight = accent.withOpacity(0.1);
  static Color accentMedium = accent.withOpacity(0.2);
  static Color accentBorder = accent.withOpacity(0.3);
  static Color accentHover = accent.withOpacity(0.6);
  static Color primaryDarkShadow = primaryDark.withOpacity(0.08);
  static Color primaryDarkLight = primaryDark.withOpacity(0.5);
  static Color primaryDarkMedium = primaryDark.withOpacity(0.6);
  static Color neutralLight = neutral.withOpacity(0.6);

  // Typography sizes (sp)
  static const double headlineSize = 36.0;
  static const double headlineSizeMobile = 28.0;
  static const double subheadlineSize = 18.0;
  static const double bodySize = 14.0;
  static const double captionSize = 12.0;

  // Spacing (8px baseline grid)
  static const double spacing1 = 8.0;
  static const double spacing2 = 16.0;
  static const double spacing3 = 24.0;
  static const double spacing4 = 32.0;
  static const double spacing5 = 40.0;
  static const double spacing6 = 48.0;

  // Border radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primaryDark.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: primaryDark.withOpacity(0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 350);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration slowAnimation = Duration(milliseconds: 600);

  // Curves
  static const Curve defaultCurve = Curves.easeOutCubic;
}
