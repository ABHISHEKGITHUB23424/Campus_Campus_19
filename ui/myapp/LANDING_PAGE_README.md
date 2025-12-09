# CampusConnect Modern Landing Page

## ✨ Features

- **Modern UI Design**: Clean, professional interface with glassmorphism effects
- **Responsive Layout**: Adapts perfectly to desktop, tablet, and mobile screens
- **Rich Animations**:
  - Hero section slide-up and fade-in
  - Feature chips with stagger animation
  - Auto-carousel phone mockup (2.5s intervals)
  - Floating background blobs
  - Hover effects on interactive elements
  - Loading spinner on CTA buttons
- **Interactive Elements**:
  - Top navigation with Login/Signup
  - Primary "Get Started" CTA with loading state
  - Secondary "Watch Demo" CTA with modal
  - Feature chips with hover states
  - Statistics counter animation
- **Production-Ready**: Optimized images, error handling, smooth transitions

---

## 📦 Required Packages

All dependencies are already added to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  lottie: ^3.3.2
  google_fonts: ^6.3.2
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10+1
```

**Run this command to install:**

```bash
flutter pub get
```

---

## 🎨 Customization Guide

### 1. **Colors** (lib/app_theme.dart)

```dart
static const Color background = Color(0xFFEEEEEE);  // Light gray
static const Color primaryDark = Color(0xFF222831); // Dark gray
static const Color neutral = Color(0xFF393E46);     // Medium gray
static const Color accent = Color(0xFF00ADB5);      // Teal/cyan
```

**To change colors:**

- Replace hex values in `app_theme.dart`
- Example: Change accent to purple → `Color(0xFF7B68EE)`

### 2. **Logo and Brand Name**

**In `modern_landing_page.dart`, locate `_buildTopNav`:**

```dart
// Change logo icon
Icon(Icons.school, ...) → Icon(Icons.your_icon, ...)

// Change app name
Text('CampusConnect', ...) → Text('YourAppName', ...)
```

### 3. **Hero Section Text**

**In `_buildHeroContent` method:**

```dart
// Main headline
Text('CampusConnect', ...) → Text('Your Headline', ...)

// Tagline
Text('Your Smart College Companion', ...) → Text('Your Tagline', ...)

// Description
Text('Attendance, Labs, Timetables & Exams — all in one place', ...)
```

### 4. **Lottie Animation**

**Replace the education Lottie animation:**

1. Visit [LottieFiles.com](https://lottiefiles.com/)
2. Search for your desired animation (e.g., "education", "campus", "learning")
3. Get the Lottie URL
4. In `_buildHeroContent`, replace:

```dart
Lottie.network(
  'https://lottie.host/YOUR_NEW_LOTTIE_URL.json',
  fit: BoxFit.contain,
),
```

### 5. **Phone Mockup Screenshots**

**In `_ModernLandingPageState` initState:**

```dart
final List<String> _mockupScreens = [
  'https://your-image-url.com/attendance-screen.png',
  'https://your-image-url.com/lab-screen.png',
  'https://your-image-url.com/timetable-screen.png',
];
```

**Recommended:**

- Use actual screenshots of your app
- Size: 400x800px (phone aspect ratio)
- Upload to cloud storage (Firebase Storage, AWS S3, Imgur)
- Replace placeholder Unsplash URLs

### 6. **Feature Chips**

**In `_buildFeatureChips` method:**

```dart
final features = [
  {'icon': Icons.fact_check_outlined, 'label': 'Attendance'},
  {'icon': Icons.computer_outlined, 'label': 'Lab Occupancy'},
  {'icon': Icons.calendar_today_outlined, 'label': 'Timetable'},
  {'icon': Icons.event_seat_outlined, 'label': 'Exam Seating'},
];
```

**To change:**

- Replace `Icons.xxx` with your preferred icons
- Change `label` text
- Add/remove items from the list

### 7. **Statistics Numbers**

**In `_buildStatisticsStrip` method:**

```dart
final stats = [
  {'value': '12k', 'label': 'Students'},
  {'value': '200', 'label': 'Labs'},
  {'value': '5k', 'label': 'Daily Records'},
];
```

**To update:**

- Change `value` (supports numbers like `100`, `1k`, `5.2k`)
- Change `label` to match your metrics

### 8. **Animation Speeds**

**In `app_theme.dart`:**

```dart
static const Duration fastAnimation = Duration(milliseconds: 350);
static const Duration mediumAnimation = Duration(milliseconds: 500);
static const Duration slowAnimation = Duration(milliseconds: 600);
```

**Carousel speed (in `modern_landing_page.dart`):**

```dart
Timer.periodic(const Duration(milliseconds: 2500), ...) // Change 2500
```

### 9. **Footer Links**

**In `_buildFooter` method:**

```dart
TextButton(
  onPressed: () {
    // Add navigation or URL launch
    Navigator.push(...) or launch('https://yourwebsite.com')
  },
  child: Text('About'),
),
```

---

## 🚀 Asset Setup

### Local Lottie Animation (Optional)

If you want to use local Lottie files instead of network:

1. Download `.json` file from LottieFiles
2. Place in `assets/lottie/your-animation.json`
3. Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/lottie/
```

4. Change code to:

```dart
Lottie.asset('assets/lottie/your-animation.json')
```

### Using Local Images for Phone Mockup

1. Add screenshots to `assets/mockups/`
2. Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/mockups/
```

3. Replace in code:

```dart
final List<String> _mockupScreens = [
  'assets/mockups/screen1.png',
  'assets/mockups/screen2.png',
  'assets/mockups/screen3.png',
];

// And change CachedNetworkImage to Image.asset
Image.asset(_mockupScreens[_currentMockupScreen], fit: BoxFit.cover)
```

---

## 🎯 Quick Wins

### Make Background Darker

```dart
// In app_theme.dart
static const Color background = Color(0xFF1A1A1A); // Dark mode
```

### Add More Floating Blobs

**In `_buildAnimatedBackground` method, duplicate Positioned widgets:**

```dart
Positioned(
  top: 300 + math.sin(_blobController.value * 3 * math.pi) * 60,
  left: 200,
  child: Container(width: 200, height: 200, ...),
),
```

### Change Button Style

**In `_buildPrimaryCTA`:**

```dart
ElevatedButton.styleFrom(
  backgroundColor: AppTheme.primaryDark, // Change color
  padding: EdgeInsets.all(24), // Bigger button
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Square corners
)
```

---

## 🐛 Troubleshooting

### Animation Not Smooth

- Reduce blob animation complexity
- Lower image quality in phone mockup
- Use `const` widgets where possible

### Images Not Loading

- Check internet connection
- Verify image URLs are valid
- Add error handling in `CachedNetworkImage.errorWidget`

### Layout Overflow

- Wrap content in `SingleChildScrollView`
- Reduce padding/spacing values
- Test on different screen sizes

### Lottie Not Playing

- Verify JSON URL is accessible
- Check Lottie package version compatibility
- Try local asset instead of network

---

## 📱 Responsive Breakpoints

```dart
final isDesktop = size.width > 900;   // Desktop: 2-column layout
final isTablet = size.width > 600 && size.width <= 900;  // Tablet
final isMobile = size.width <= 600;   // Mobile: Stacked layout
```

---

## 🔗 Navigation Flow

```
ModernLandingPage ('/')
  → LoginSelectionPage ('/loginSelection')
    → StudentLoginPage ('/studentLogin') → Home ('/home')
    → StaffLoginPage ('/staffLogin') → Home ('/home')
    → ManagementLoginPage ('/managementLogin') → Home ('/home')
```

---

## 📝 Notes

- **Phone mockup images**: Replace Unsplash placeholders with actual app screenshots
- **Lottie animation**: Choose one that matches your app's theme
- **Statistics**: Update with real metrics from your database
- **Demo modal**: Implement video player or link to YouTube

---

## 🎉 Next Steps

1. Run `flutter pub get` to install all packages
2. Hot reload the app to see the new landing page
3. Customize colors, text, and images
4. Test on multiple screen sizes (desktop, tablet, mobile)
5. Replace placeholder assets with production-ready content
6. Add analytics tracking to CTAs
7. Implement deep linking for external marketing

---

**Need help?** Check the inline code comments in `modern_landing_page.dart` for detailed explanations of each section.
