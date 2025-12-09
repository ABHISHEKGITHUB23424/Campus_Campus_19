# Professor Navigation Shell - Implementation Guide

## Overview

A professional, adaptive navigation system for the CampusConnect professor mobile app. Automatically switches between bottom navigation (phones) and navigation rail (tablets/wide screens).

## Theme Colors

```dart
Background:  #EEEEEE
Primary:     #222831
Secondary:   #393E46
Accent:      #00ADB5
```

## Features

- ✅ Adaptive layout (bottom nav / rail based on screen width)
- ✅ State preservation with `IndexedStack` + nested navigators
- ✅ Badge support for notifications (Attendance tab)
- ✅ Smooth animations and transitions
- ✅ Back button handling (per-tab navigation stacks)
- ✅ Accessibility (tooltips, semantic labels, min touch targets)
- ✅ FAB for quick attendance access
- ✅ Auto-keep-alive for all pages

## Navigation Items

1. **Home** - Welcome + overview

   - Icon: `Icons.home_outlined`
   - Shows quick stats, recent activity

2. **Attendance** - Quick take attendance

   - Icon: `Icons.fact_check_outlined`
   - Badge: Shows pending attendance count
   - Quick access via FAB

3. **Occupancy** - Lab & class occupancy

   - Icon: `Icons.meeting_room_outlined`
   - Tabs for Labs and Classrooms
   - Real-time occupancy tracking

4. **Timetable** - Class schedule

   - Icon: `Icons.calendar_today_outlined`
   - Day selector, class cards

5. **Profile** - Settings & logout
   - Icon: `Icons.person_outline`
   - User info, settings, logout

## File Structure

```
lib/
├── main.dart              # App entry point
├── welcome_screen.dart    # Login/welcome (existing)
├── prof_shell.dart        # Main navigation shell ⭐
├── home_page.dart         # Home tab
├── attendance_page.dart   # Attendance tab
├── occupancy_page.dart    # Occupancy tab
├── timetable_page.dart    # Timetable tab
└── profile_page.dart      # Profile tab
```

## Usage

### 1. After Login Navigation

Replace the welcome screen navigation with ProfShell:

```dart
// After successful login
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const ProfShell()),
);
```

### 2. Navigate to Specific Tab

```dart
// Pass initial tab index to ProfShell
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const ProfShell(initialTab: 1), // Attendance
  ),
);
```

### 3. Nested Navigation Example

From any page, push a detail view:

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => DetailPage()),
);
```

The navigation bar remains visible, and back button will pop the detail page first.

### 4. Full-Screen Pages (Hide Nav Bar)

For full-screen views like live camera:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => FullScreenPage(),
    fullscreenDialog: true,
  ),
);
```

### 5. Update Badge Count

```dart
// In ProfShell state
setState(() {
  _attendanceBadgeCount = 5; // New pending count
});
```

For global state management, use Provider/Riverpod/Bloc:

```dart
// Example with Provider
context.read<AttendanceProvider>().updateBadgeCount(5);
```

## Responsive Behavior

- **Phone (width ≤ 700px)**: Bottom navigation bar
- **Tablet/Desktop (width > 700px)**: Left navigation rail (extended labels)

## Back Button Behavior

1. If current tab has nested routes → Pop the route
2. If at root of non-home tab → Switch to Home tab
3. If at root of Home tab → Show exit confirmation dialog
4. User confirms exit → Close app

## Accessibility Features

- Minimum touch target: 48x48 dp
- Tooltips on all nav items
- Semantic labels for screen readers
- High contrast colors (WCAG compliant)
- Smooth animations (ease-out curves)

## Customization

### Change Badge Count

Edit `prof_shell.dart`:

```dart
int _attendanceBadgeCount = 3; // Change initial value
```

### Add New Tab

1. Create new page file (e.g., `exams_page.dart`)
2. Add to `_navigatorKeys` list in `prof_shell.dart`
3. Add to `IndexedStack` children
4. Add to navigation destinations
5. Update `_cardAnimationStates` map if needed

### Modify Colors

Replace color values in all files:

```dart
const Color(0xFF00ADB5) // Accent
const Color(0xFF222831) // Primary
const Color(0xFF393E46) // Secondary
const Color(0xFFEEEEEE) // Background
```

## State Management

All pages use `AutomaticKeepAliveClientMixin` to preserve:

- Scroll positions
- Form inputs
- Tab selections
- Animation states

## Performance Tips

1. Use `const` constructors where possible
2. `IndexedStack` prevents rebuilding inactive tabs
3. Nested navigators keep each tab's route stack separate
4. Keep heavy operations in async/isolates

## Suggested Packages (Optional)

```yaml
dependencies:
  # Already included:
  flutter:
    sdk: flutter

  # Optional enhancements:
  # badges: ^3.1.2              # Alternative badge implementation
  # animations: ^2.0.11          # Page transition animations
  # provider: ^6.1.1             # State management
  # flutter_riverpod: ^2.4.9     # Alternative state management
```

## Testing Navigation

1. Run the app: `flutter run -d windows`
2. Test tab switching (state should persist)
3. Test nested navigation (push detail pages)
4. Test back button behavior
5. Resize window to test responsive layout
6. Test FAB on different tabs

## Integration Checklist

- [ ] All page files created
- [ ] Import statements correct
- [ ] Navigation flow from login to ProfShell
- [ ] Badge count updates working
- [ ] Back button handling tested
- [ ] Responsive layout tested (phone + tablet)
- [ ] Accessibility verified
- [ ] State preservation confirmed

## Common Issues

**Issue**: State not preserved when switching tabs
**Solution**: Ensure `AutomaticKeepAliveClientMixin` is used and `super.build(context)` is called

**Issue**: Back button exits app immediately
**Solution**: Check `PopScope` implementation in `prof_shell.dart`

**Issue**: Navigation rail not showing
**Solution**: Verify screen width > 700px or adjust breakpoint

**Issue**: Badge not updating
**Solution**: Call `setState()` or use state management solution

## Next Steps

1. Integrate with backend API for real data
2. Add push notifications for attendance reminders
3. Implement deep linking for specific tabs
4. Add analytics tracking
5. Implement offline mode with local storage

---

**Created**: November 2025  
**Version**: 1.0.0  
**License**: MIT
