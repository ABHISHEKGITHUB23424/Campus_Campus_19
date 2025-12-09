import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'features/exam_seating/pages/management_page.dart';
import 'timetable_page.dart';
import 'occupancy_page.dart';
import 'attendance_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  // Footer state
  int selectedIndex = 0;
  bool isDarkMode = true; // Default dark mode

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 1,
        title: const Text(
          'CampusConnect',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00ADB5),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person_outline,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            _welcomeCard(),
            const SizedBox(height: 20),
            _quickStats(),
            const SizedBox(height: 24),
            _featureGrid(),
            const SizedBox(height: 24),
            _recentActivity(),
          ],
        ),
      ),
      bottomNavigationBar: buildFooter(),
    );
  }

  // ----------------------------- Welcome Card -----------------------------
  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00ADB5), Color(0xFF0D939A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome Back 👋",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You have 3 classes today",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------- Quick Stats -----------------------------
  Widget _quickStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.class_outlined,
            label: "Classes Today",
            value: "3",
            color: const Color(0xFF00ADB5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.pending_actions_outlined,
            label: "Pending Tasks",
            value: "7",
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF222831),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------- Feature Grid -----------------------------
  Widget _featureGrid() {
    List<Map<String, dynamic>> features = [
      {
        "label": "Attendance",
        "icon": Icons.fact_check_outlined,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendancePage()),
          );
        },
      },
      {
        "label": "Timetable",
        "icon": Icons.calendar_today_outlined,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimetablePage()),
          );
        },
      },
      {
        "label": "Room Occupancy",
        "icon": Icons.meeting_room_outlined,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OccupancyPage()),
          );
        },
      },
      {
        "label": "Exam Seating",
        "icon": Icons.event_seat_outlined,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ExamSeatingManagementPage(),
            ),
          );
        },
      },
      {
        "label": "Management",
        "icon": Icons.admin_panel_settings_outlined,
        "action": () {
          Navigator.pushNamed(context, "/managementLogin");
        },
      },
      {
        "label": "More",
        "icon": Icons.apps_outlined,
        "action": () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("More Features Coming Soon")),
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Features",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00ADB5),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: features.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final f = features[index];
            return GestureDetector(
              onTap: f["action"],
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(f["icon"], size: 34, color: const Color(0xFF00ADB5)),
                    const SizedBox(height: 10),
                    Text(
                      f["label"],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ----------------------------- Recent Activity -----------------------------
  Widget _recentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00ADB5),
          ),
        ),
        const SizedBox(height: 12),
        _activityCard(
          icon: Icons.check_circle_outline,
          title: "Attendance marked for CS101",
          time: "2 hours ago",
        ),
        _activityCard(
          icon: Icons.update,
          title: "Lab B2 occupancy updated",
          time: "5 hours ago",
        ),
        _activityCard(
          icon: Icons.edit_calendar_outlined,
          title: "Timetable modified",
          time: "Yesterday",
        ),
      ],
    );
  }

  Widget _activityCard({
    required IconData icon,
    required String title,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00ADB5).withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF00ADB5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------- Footer -----------------------------
  Widget buildFooter() {
    List<Map<String, dynamic>> footerFeatures = [
      {
        "label": "Attendance",
        "icon": Icons.fact_check_outlined,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendancePage()),
          );
        },
      },
      {
        "label": "Timetable",
        "icon": Icons.calendar_today_outlined,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimetablePage()),
          );
        },
      },
      {
        "label": "Exam Seating",
        "icon": Icons.event_seat_outlined,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ExamSeatingManagementPage(),
            ),
          );
        },
      },
      {
        "label": "Room Occupancy",
        "icon": Icons.meeting_room_outlined,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OccupancyPage()),
          );
        },
      },
      {
        "label": "Management",
        "icon": Icons.admin_panel_settings_outlined,
        "action": () {
          Navigator.pushNamed(context, "/managementLogin");
        },
      },
    ];

    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withOpacity(0.4)
            : Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < 2; i++) navFeatureIcon(footerFeatures[i], i),
          Transform.translate(
            offset: const Offset(0, -20),
            child: GestureDetector(
              onTap: footerFeatures[2]["action"],
              child: Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? Colors.blueGrey[900] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  footerFeatures[2]["icon"],
                  size: 32,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          for (int i = 3; i < 5; i++) navFeatureIcon(footerFeatures[i], i),
        ],
      ),
    );
  }

  Widget navFeatureIcon(Map<String, dynamic> feature, int index) {
    bool selected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        feature["action"]();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(selected ? 10 : 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDarkMode ? Colors.white12 : Colors.black12)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          feature["icon"],
          size: selected ? 30 : 26,
          color: selected
              ? (isDarkMode ? Colors.white : Colors.black)
              : (isDarkMode ? Colors.white54 : Colors.black54),
        ),
      ),
    );
  }
}

// ----------------------------- Notifications -----------------------------
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.black,
      ),
      body: const Center(child: Text("Notifications Page")),
    );
  }
}
