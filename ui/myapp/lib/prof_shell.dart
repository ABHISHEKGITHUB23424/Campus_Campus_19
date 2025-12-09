/*
 * PROFESSOR NAVIGATION SHELL
 * 
 * A persistent navigation wrapper for the professor mobile app.
 * Shows bottom navigation on phones, left rail on tablets/wide screens.
 * 
 * THEME COLORS:
 * - Background: #EEEEEE
 * - Primary: #222831
 * - Secondary: #393E46
 * - Accent: #00ADB5
 * 
 * FEATURES:
 * - Adaptive navigation (bottom bar / rail)
 * - State preservation with IndexedStack + nested Navigators
 * - Badge support for notifications
 * - Smooth animations
 * - Accessibility support
 * 
 * USAGE:
 * After login, navigate to:
 * Navigator.pushReplacement(
 *   context,
 *   MaterialPageRoute(builder: (context) => const ProfShell()),
 * );
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'attendance_page.dart';
import 'occupancy_page.dart';
import 'features/exam_seating/pages/seating_page.dart';
import 'timetable_page.dart';

class ProfShell extends StatefulWidget {
  const ProfShell({super.key});

  @override
  State<ProfShell> createState() => _ProfShellState();
}

class _ProfShellState extends State<ProfShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final int _attendanceBadgeCount = 3; // Simulate pending attendance actions
  late AnimationController _fabController;

  // Global keys for nested navigators
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Home
    GlobalKey<NavigatorState>(), // Attendance
    GlobalKey<NavigatorState>(), // Occupancy
    GlobalKey<NavigatorState>(), // Seating
    GlobalKey<NavigatorState>(), // Timetable
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    // Guard against invalid index
    if (_currentIndex < 0 || _currentIndex >= _navigatorKeys.length) {
      return false;
    }

    final isFirstRouteInCurrentTab = !await _navigatorKeys[_currentIndex]
        .currentState!
        .maybePop();

    if (isFirstRouteInCurrentTab) {
      // If not on home tab, go to home
      if (_currentIndex != 0) {
        _selectTab(0);
        return false;
      }
      // On home tab, show exit confirmation
      return await _showExitDialog() ?? false;
    }
    return false;
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );
  }

  void _selectTab(int index) {
    // Clamp index to available tabs
    if (index < 0 || index >= _navigatorKeys.length) {
      return;
    }

    if (_currentIndex == index) {
      // Pop to first route if tapped again
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  int _clampIndex(int index, int maxCount) {
    if (maxCount <= 0) return 0;
    if (index < 0) return 0;
    if (index >= maxCount) return maxCount - 1;
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 700;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Logged in as Guest',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00ADB5).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00ADB5).withOpacity(0.5),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lock_open,
                            size: 14,
                            color: Color(0xFF00ADB5),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Auth Disabled',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00ADB5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Row(
          children: [
            // Navigation Rail for wide screens
            if (isWideScreen) _buildNavigationRail(),

            // Main content area with nested navigators
            Expanded(
              child: IndexedStack(
                index: _clampIndex(_currentIndex, 5),
                children: [
                  _buildNavigator(0, const HomePage()),
                  _buildNavigator(1, const AttendancePage()),
                  _buildNavigator(2, const OccupancyPage()),
                  _buildNavigator(3, const SeatingPage()),
                  _buildNavigator(4, const TimetablePage()),
                ],
              ),
            ),
          ],
        ),

        // Bottom Navigation for phones
        bottomNavigationBar: isWideScreen ? null : _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildNavigator(int index, Widget page) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => page,
          settings: settings,
        );
      },
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _clampIndex(_currentIndex, 5),
      onDestinationSelected: _selectTab,
      backgroundColor: const Color(0xFF1A1A1A),
      selectedIconTheme: const IconThemeData(
        color: Color(0xFF00ADB5),
        size: 28,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: Color(0xFF00ADB5),
        fontWeight: FontWeight.w600,
      ),
      unselectedIconTheme: const IconThemeData(color: Colors.white30, size: 24),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white30),
      labelType: NavigationRailLabelType.all,
      elevation: 2,
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: _buildBadge(Icons.fact_check_outlined, _attendanceBadgeCount),
          selectedIcon: _buildBadge(Icons.fact_check, _attendanceBadgeCount),
          label: const Text('Attendance'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.meeting_room_outlined),
          selectedIcon: Icon(Icons.meeting_room),
          label: Text('Occupancy'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.event_seat_outlined),
          selectedIcon: Icon(Icons.event_seat),
          label: Text('Seating'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: Text('Timetable'),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.fact_check_outlined,
                selectedIcon: Icons.fact_check,
                label: 'Attendance',
                hasBadge: true,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.meeting_room_outlined,
                selectedIcon: Icons.meeting_room,
                label: 'Occupancy',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.event_seat_outlined,
                selectedIcon: Icons.event_seat,
                label: 'Seating',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.calendar_today_outlined,
                selectedIcon: Icons.calendar_today,
                label: 'Timetable',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool hasBadge = false,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00ADB5).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: hasBadge
                    ? _buildBadge(
                        isSelected ? selectedIcon : icon,
                        _attendanceBadgeCount,
                      )
                    : Icon(
                        isSelected ? selectedIcon : icon,
                        color: isSelected
                            ? const Color(0xFF00ADB5)
                            : Colors.white30,
                        size: isSelected ? 26 : 24,
                      ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00ADB5) : Colors.white70,
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, int count) {
    if (count == 0) return Icon(icon);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              count > 9 ? '9+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/*
 * INTEGRATION NOTES:
 * 
 * 1. After successful login, navigate to ProfShell:
 *    Navigator.pushReplacement(
 *      context,
 *      MaterialPageRoute(builder: (context) => const ProfShell()),
 *    );
 * 
 * 2. To hide navigation on specific pages (e.g., full-screen view):
 *    - Push a new route that doesn't use ProfShell
 *    - Or use a route with fullscreenDialog: true
 * 
 * 3. Deep linking example (select specific tab):
 *    - Add route parameter to ProfShell constructor
 *    - Initialize _currentIndex based on route
 * 
 * 4. Update badge count:
 *    - Use setState or state management (Provider, Riverpod, Bloc)
 *    - Example: _attendanceBadgeCount = newCount
 * 
 * 5. Nested navigation example:
 *    From any page, push a detail view:
 *    Navigator.of(context).push(
 *      MaterialPageRoute(builder: (context) => DetailPage()),
 *    );
 */