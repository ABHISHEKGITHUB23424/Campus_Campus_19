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
    with AutomaticKeepAliveClientMixin {
  final String backend = getBackendBaseUrl(); // backend URL helper

  int labA1 = 0, labA2 = 0, labB1 = 0, labB2 = 0, labC1 = 0;
  bool processing = false;
  String processingLab = '';

  Timer? timer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    startPolling();
  }

  @override
  void dispose() {
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          '🏫 Lab Occupancy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: _buildLabsView(),
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
        _buildOccupancyCard(
          'NETWORK LAB',
          labA2,
          30,
          Icons.computer,
          (processing && processingLab == 'NETWORK LAB'),
        ),
        _buildOccupancyCard(
          'LANGUAGE LAB',
          labB1,
          25,
          Icons.computer,
          (processing && processingLab == 'LANGUAGE LAB'),
        ),
        _buildOccupancyCard(
          'MOCK LAB',
          labB2,
          25,
          Icons.computer,
          (processing && processingLab == 'MOCK LAB'),
        ),
        _buildOccupancyCard(
          'ILP LAB',
          labC1,
          30,
          Icons.computer,
          (processing && processingLab == 'ILP LAB'),
        ),
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
    if (percentage >= 90) {
      statusColor = Colors.red;
    } else if (percentage >= 70) {
      statusColor = Colors.orange;
    } else if (percentage > 0) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
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
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
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
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          processing
                              ? "🔄 Processing..."
                              : "$occupied / $capacity occupied",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
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
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 2),
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
                  backgroundColor: const Color(0xFF2A2A2A),
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
