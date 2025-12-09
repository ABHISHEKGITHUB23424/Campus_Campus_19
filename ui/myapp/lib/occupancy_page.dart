import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'lab_detail_page.dart';
import 'backend.dart';

class OccupancyPage extends StatefulWidget {
  const OccupancyPage({super.key});

  @override
  State<OccupancyPage> createState() => _OccupancyPageState();
}

class _OccupancyPageState extends State<OccupancyPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final String backend = getBackendBaseUrl(); // backend URL helper

  int labA1 = 0, labA2 = 0, labB1 = 0, labB2 = 0, labC1 = 0;
  bool processing = false;
  String processingLab = '';

  Timer? timer;
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    startPolling();
  }

  @override
  void dispose() {
    _tabController.dispose();
    timer?.cancel();
    super.dispose();
  }

  // ------------------------
  // Poll backend every 1 sec
  // ------------------------
  void startPolling() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final res = await http.get(Uri.parse("$backend/count"));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final labs = data["labs"] ?? {};
          setState(() {
            labA1 = labs["Python LAB"] ?? 0;
            labA2 = labs["NETWORK LAB"] ?? 0;
            labB1 = labs["LANGUAGE LAB"] ?? 0;
            labB2 = labs["MOCK LAB"] ?? 0;
            labC1 = labs["ILP LAB"] ?? 0;
            processing = data["processing"] ?? false;
            processingLab = data["processing_lab"] ?? '';
          });
        }
      } catch (e) {
        // handle errors silently
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '🏫 Lab Occupancy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF00ADB5),
        elevation: 8,
        shadowColor: const Color(0xFF00ADB5).withOpacity(0.5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            tabs: const [
              Tab(text: '💻 Labs'),
              Tab(text: '🏢 Classrooms'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLabsView(), _buildClassroomsView()],
      ),
    );
  }

  Widget _buildLabsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOccupancyCard(
          'Python LAB',
          labA1,
          30,
          Icons.computer,
          (processing && processingLab == 'Python LAB'),
        ),
        _buildOccupancyCard('NETWORK LAB', labA2, 30, Icons.computer, (processing && processingLab == 'NETWORK LAB')),
        _buildOccupancyCard('LANGUAGE LAB', labB1, 25, Icons.computer, (processing && processingLab == 'LANGUAGE LAB')),
        _buildOccupancyCard('MOCK LAB', labB2, 25, Icons.computer, (processing && processingLab == 'MOCK LAB')),
        _buildOccupancyCard('ILP LAB', labC1, 30, Icons.computer, (processing && processingLab == 'ILP LAB')),
      ],
    );
  }

  Widget _buildClassroomsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOccupancyCard('Room 101', 45, 50, Icons.meeting_room, false),
        _buildOccupancyCard('Room 102', 50, 50, Icons.meeting_room, false),
        _buildOccupancyCard('Room 201', 30, 60, Icons.meeting_room, false),
        _buildOccupancyCard('Room 202', 0, 60, Icons.meeting_room, false),
        _buildOccupancyCard('Room 301', 55, 80, Icons.meeting_room, false),
      ],
    );
  }

  Widget _buildOccupancyCard(
    String name,
    int occupied,
    int capacity,
    IconData icon,
    bool processing,
  ) {
    final double percentage = (capacity > 0)
        ? (occupied / capacity) * 100
        : 0.0;

    Color statusColor;
    Color gradientStart;
    Color gradientEnd;
    if (percentage >= 90) {
      statusColor = Colors.red;
      gradientStart = Colors.red.withOpacity(0.8);
      gradientEnd = Colors.redAccent.withOpacity(0.4);
    } else if (percentage >= 70) {
      statusColor = Colors.orange;
      gradientStart = Colors.orange.withOpacity(0.8);
      gradientEnd = Colors.amber.withOpacity(0.4);
    } else if (percentage > 0) {
      statusColor = Colors.green;
      gradientStart = Colors.green.withOpacity(0.8);
      gradientEnd = Colors.teal.withOpacity(0.4);
    } else {
      statusColor = Colors.grey;
      gradientStart = Colors.grey.withOpacity(0.6);
      gradientEnd = Colors.blueGrey.withOpacity(0.3);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => LabDetailPage(labName: name)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.85),
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.3),
                          statusColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: statusColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222831),
                          ),
                        ),
                        Text(
                          processing
                              ? "🔄 Processing..."
                              : "$occupied / $capacity occupied",
                          style: TextStyle(
                            fontSize: 13,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.15),
                          statusColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
