# CampusConnect Theme Guide

## Overview

This guide documents the white background theme used consistently across all pages in the CampusConnect app.

## Color Palette

### Primary Colors

```dart
AppTheme.background          // #FFFFFF - Primary white background
AppTheme.backgroundGradient  // #F5F5F5 - Subtle gradient accent
AppTheme.primaryDark         // #222831 - Text and UI elements
AppTheme.neutral             // #393E46 - Secondary text
AppTheme.white               // #FFFFFF - Pure white
```

### Accent Colors

```dart
AppTheme.accent              // #00ADB5 - Primary accent (cyan/teal)
AppTheme.accentGreen         // #00C9A7 - Secondary accent (green)
AppTheme.accentPurple        // #845EC2 - Tertiary accent (purple)
```

### UI Element Colors

```dart
AppTheme.cardBackground      // #FAFAFA - Card gradient end color
AppTheme.borderLight         // #E0E0E0 - Default borders
AppTheme.infoBackground      // #F5F5F5 - Info boxes, footer notes
```

### Opacity Variations

```dart
AppTheme.accentLight         // accent.withOpacity(0.1)  - Subtle backgrounds
AppTheme.accentMedium        // accent.withOpacity(0.2)  - Medium backgrounds
AppTheme.accentBorder        // accent.withOpacity(0.3)  - Borders
AppTheme.accentHover         // accent.withOpacity(0.6)  - Hover states
AppTheme.primaryDarkShadow   // primaryDark.withOpacity(0.08) - Soft shadows
AppTheme.primaryDarkLight    // primaryDark.withOpacity(0.5)  - Light text
AppTheme.primaryDarkMedium   // primaryDark.withOpacity(0.6)  - Medium text
AppTheme.neutralLight        // neutral.withOpacity(0.6)      - Secondary text
```

## Typography

### Font Sizes

```dart
AppTheme.headlineSize        // 36.0 - Main headlines (desktop)
AppTheme.headlineSizeMobile  // 28.0 - Main headlines (mobile)
AppTheme.subheadlineSize     // 18.0 - Subheadings
AppTheme.bodySize            // 14.0 - Body text
AppTheme.captionSize         // 12.0 - Captions, small text
```

### Font Usage

- Use **Google Fonts Inter** for all text (already configured in landing page)
- Headlines: Bold weight (FontWeight.bold)
- Body text: Regular weight (FontWeight.normal)
- Accents: Semi-bold (FontWeight.w600)

## Spacing (8px baseline grid)

```dart
AppTheme.spacing1  // 8px  - Tight spacing
AppTheme.spacing2  // 16px - Standard spacing
AppTheme.spacing3  // 24px - Medium spacing
AppTheme.spacing4  // 32px - Large spacing
AppTheme.spacing5  // 40px - Extra large spacing
AppTheme.spacing6  // 48px - Section spacing
```

## Border Radius

```dart
AppTheme.radiusSmall   // 12px - Small elements
AppTheme.radiusMedium  // 16px - Standard cards
AppTheme.radiusLarge   // 20px - Large cards, modals
```

## Shadows

```dart
AppTheme.softShadow    // Light shadow for cards
AppTheme.mediumShadow  // Prominent shadow for elevated cards
```

## Animation

```dart
AppTheme.fastAnimation    // 350ms - Quick transitions
AppTheme.mediumAnimation  // 500ms - Standard animations
AppTheme.slowAnimation    // 600ms - Slow, smooth animations
AppTheme.defaultCurve     // Curves.easeOutCubic
```

## Page Structure Template

### Standard Page Layout

```dart
Scaffold(
  backgroundColor: Colors.white,
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppTheme.primaryDark),
    title: Text(
      'Page Title',
      style: TextStyle(
        color: AppTheme.primaryDark,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  ),
  body: Stack(
    children: [
      // Animated background gradient
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppTheme.backgroundGradient,
                  Colors.white,
                ],
              ),
            ),
          );
        },
      ),

      // Floating accent blobs (optional)
      _buildFloatingBlobs(),

      // Main content
      SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            children: [
              // Your content here
            ],
          ),
        ),
      ),
    ],
  ),
)
```

### Glass Card Component

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        AppTheme.cardBackground,
      ],
    ),
    border: Border.all(
      color: isHovered
          ? AppTheme.accentHover
          : AppTheme.borderLight,
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: isHovered
            ? AppTheme.accent.withOpacity(0.3)
            : AppTheme.primaryDarkShadow,
        blurRadius: isHovered ? 24 : 16,
        offset: Offset(0, 8),
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
          padding: EdgeInsets.all(AppTheme.spacing3),
          child: YourContent(),
        ),
      ],
    ),
  ),
)
```

### Info Box / Footer Note

```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppTheme.spacing3,
    vertical: AppTheme.spacing2,
  ),
  decoration: BoxDecoration(
    color: AppTheme.infoBackground,
    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
    border: Border.all(
      color: AppTheme.accentBorder,
      width: 1,
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.info_outline_rounded,
        size: 16,
        color: AppTheme.primaryDarkLight,
      ),
      SizedBox(width: 8),
      Text(
        'Your message here',
        style: TextStyle(
          fontSize: AppTheme.captionSize,
          color: AppTheme.primaryDarkLight,
        ),
      ),
    ],
  ),
)
```

### Badge / Pill

```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppTheme.spacing3,
    vertical: 8,
  ),
  decoration: BoxDecoration(
    color: AppTheme.accentLight,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppTheme.accentBorder,
      width: 1,
    ),
  ),
  child: Text(
    'Badge Text',
    style: TextStyle(
      fontSize: 14,
      color: AppTheme.accent,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
    ),
  ),
)
```

## Existing Pages Using Theme

### ✅ Modern Landing Page (`modern_landing_page.dart`)

- Uses `AppTheme.background` for scaffold
- Uses theme constants throughout
- Animated background blobs

### ✅ Login Selection Page (`login_selection_page.dart`)

- White background with subtle gradient
- Glass cards with hover effects
- Floating accent blobs
- Three accent colors for different portals

## Guidelines for New Pages

1. **Always use** `AppTheme.background` (white) for scaffold background
2. **Use** subtle gradient with `AppTheme.backgroundGradient` for depth
3. **Add** floating accent blobs for visual interest (optional but recommended)
4. **Use** glass cards with white + `AppTheme.cardBackground` gradient
5. **Text colors**: `AppTheme.primaryDark` for primary text, `AppTheme.primaryDarkMedium` for secondary
6. **Borders**: `AppTheme.borderLight` default, accent colors on hover
7. **Shadows**: Use `AppTheme.softShadow` or `AppTheme.mediumShadow`
8. **Spacing**: Follow 8px grid using `AppTheme.spacing*` constants
9. **Animations**: Use `AppTheme.*Animation` durations with `AppTheme.defaultCurve`

## Color Combinations

### Primary Action Buttons

- Background: `AppTheme.accent`
- Text: `Colors.white`
- Hover: Increase elevation, add shadow

### Secondary Buttons

- Background: `AppTheme.accentLight`
- Text: `AppTheme.accent`
- Border: `AppTheme.accentBorder`

### Text Hierarchy

- H1: `AppTheme.primaryDark` + Bold
- H2/H3: `AppTheme.primaryDark` + Semi-bold
- Body: `AppTheme.primaryDark` + Regular
- Caption: `AppTheme.primaryDarkMedium` + Regular

### Card States

- Default: White background, `AppTheme.borderLight` border
- Hover: Accent border, elevated shadow
- Active: Accent background tint

## Accessibility

- Ensure text contrast ratio ≥ 4.5:1 (white bg + dark text = excellent)
- Hover states must be visible (border color change + shadow)
- Interactive elements min size: 48x48 dp
- Adequate spacing between interactive elements (min 8px)

## Examples in Action

Check these files for reference:

- `login_selection_page.dart` - Complete implementation
- `modern_landing_page.dart` - Landing page with theme
- `app_theme.dart` - All theme constants

---

**Remember**: Consistency is key! Always import and use `app_theme.dart` constants rather than hardcoding values.
