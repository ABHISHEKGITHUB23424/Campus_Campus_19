import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_page.dart';
import 'features/attendance/pages/class_selector_page.dart';
import 'features/attendance/pages/student_list_page.dart';
import 'features/attendance/pages/attendance_summary_page.dart';
import 'features/attendance/pages/student_report_page.dart';

/// Attendance Module - Dashboard with quick actions
/// Part of the unified attendance management system
///
/// Structure:
/// - lib/features/attendance/
///   ├── pages/           (All attendance screens)
///   ├── controllers/     (Riverpod state management)
///   ├── data/           (API services & models)
///   └── widgets/        (Reusable components)
class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white54,
                          ),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00ADB5).withOpacity(0.2),
                                const Color(0xFF00ADB5).withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00ADB5).withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.fact_check,
                            color: Color(0xFF00ADB5),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage student attendance',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_outline),
                          color: Colors.white54,
                          iconSize: 24,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },
                          tooltip: 'Profile',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action Cards
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildListDelegate([
                  _buildModernActionCard(
                    context,
                    title: 'Take Attendance',
                    subtitle: 'Mark present/absent',
                    icon: Icons.how_to_reg,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00ADB5), Color(0xFF007B82)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ClassSelectorPage(),
                        ),
                      );
                    },
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'View Summary',
                    subtitle: 'Analytics & stats',
                    icon: Icons.analytics,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00ADB5).withOpacity(0.7),
                        const Color(0xFF007B82).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AttendanceSummaryPage(),
                        ),
                      );
                    },
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Student List',
                    subtitle: 'View all students',
                    icon: Icons.people,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00ADB5).withOpacity(0.7),
                        const Color(0xFF007B82).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StudentListPage(),
                        ),
                      );
                    },
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Student Report',
                    subtitle: 'Individual reports',
                    icon: Icons.assessment,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00ADB5), Color(0xFF007B82)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StudentReportPage(),
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00ADB5).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon section with gradient
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(child: Icon(icon, size: 48, color: Colors.white)),
            ),

            // Text section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
