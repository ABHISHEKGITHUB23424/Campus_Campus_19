// lib/timetable_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  int periodsPerDay = 6;
  List<String> get periods => [for (int i = 1; i <= periodsPerDay; i++) 'P$i'];

  final List<DepartmentModel> departments = [];
  final List<RoomModel> rooms = [];
  Map<String, Map<String, Map<String, TimetableCell>>>? timetableResult;

  bool _isGenerating = false;
  String _status = '';
  final TextEditingController _deptCtl = TextEditingController();
  final TextEditingController _roomCtl = TextEditingController();
  late TabController _tabController;

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // ---------------- Sample Departments ----------------
  }

  @override
  void dispose() {
    _deptCtl.dispose();
    _roomCtl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ---------- Add department ----------
  void _addDepartment(String name) {
    if (name.trim().isEmpty) return;
    String short = name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();
    if (short.isEmpty)
      short = name.trim().substring(0, min(2, name.trim().length));
    short = short.toUpperCase();
    final defaultSection = '$short-A';
    setState(() {
      departments.add(
        DepartmentModel(name: name.trim(), groups: [defaultSection]),
      );
      _deptCtl.clear();
    });
  }

  // ---------- Solver ----------
  // ---------- Solver ----------
  void runHybridSolver({
    required int popSize,
    required int generations,
    required double mutationRate,
  }) {
    setState(() {
      _isGenerating = true;
      _status = 'Generating timetable...';
    });

    Future.delayed(const Duration(milliseconds: 500), () async {
      bool teacherClashExists = true;
      int attempts = 0;
      const maxAttempts = 1000;

      while (teacherClashExists && attempts < maxAttempts) {
        attempts++;

        final Map<String, Map<String, Map<String, TimetableCell>>> result = {};

        for (var dept in departments) {
          result[dept.name] = {};

          for (var day in days) {
            result[dept.name]![day] = {};

            for (int p = 0; p < periodsPerDay; p++) {
              // Filter sessions where teacher is free
              final availableSessions = dept.sessions
                  .where(
                    (s) => !isTeacherBusy(s.teacher, day, 'P${p + 1}', result),
                  )
                  .toList();

              if (availableSessions.isNotEmpty) {
                final s =
                    availableSessions[Random().nextInt(
                      availableSessions.length,
                    )];
                result[dept.name]![day]!['P${p + 1}'] = TimetableCell(
                  subject: s.subject,
                  teacher: s.teacher,
                  group: s.group,
                  room: rooms.isNotEmpty
                      ? rooms[Random().nextInt(rooms.length)].name
                      : 'R1',
                  day: day,
                  period: 'P${p + 1}',
                );
              } else {
                // No teacher available → leave empty
                result[dept.name]![day]!['P${p + 1}'] = TimetableCell.empty(
                  day: day,
                  period: 'P${p + 1}',
                );
              }
            }
          }
        }

        timetableResult = result;

        // Check teacher clashes
        final clashes = analyzeClashesDetailed();
        teacherClashExists = clashes['teacher']!.isNotEmpty;

        // Update status live
        setState(() {
          _status =
              'Generating timetable... Attempts: $attempts, Clashes: ${clashes['teacher']!.length}';
        });

        // Optional: small delay to let UI update
        await Future.delayed(const Duration(milliseconds: 10));
      }

      setState(() {
        _isGenerating = false;
        _status = teacherClashExists
            ? 'Failed to generate clash-free timetable after $attempts attempts. Increase rooms/periods.'
            : 'Clash-free timetable generated after $attempts attempt(s)!';
        _tabController.animateTo(2); // Show timetable
      });
    });
  }

  // ---------- Helper: Check if teacher is busy ----------
  bool isTeacherBusy(
    String teacher,
    String day,
    String period,
    Map<String, Map<String, Map<String, TimetableCell>>> currentResult,
  ) {
    for (var deptMap in currentResult.values) {
      if (deptMap[day]?[period]?.teacher == teacher) return true;
    }
    return false;
  }

  // ---------- Analyze Clashes ----------
  Map<String, List<String>> analyzeClashesDetailed() {
    final Map<String, List<String>> clashes = {
      'teacher': [],
      'group': [],
      'room': [],
    };
    if (timetableResult == null) return clashes;

    final Map<String, Set<String>> teacherMap = {};
    final Map<String, Set<String>> groupMap = {};
    final Map<String, Set<String>> roomMap = {};

    timetableResult!.forEach((deptName, dayMap) {
      dayMap.forEach((day, periodMap) {
        periodMap.forEach((period, cell) {
          if (cell.isEmpty) return;
          final key = '$day-$period';

          teacherMap[cell.teacher ?? ''] ??= {};
          if (!teacherMap[cell.teacher!]!.add(key)) {
            clashes['teacher']!.add('${cell.teacher} clash at $key');
          }

          groupMap[cell.group ?? ''] ??= {};
          if (!groupMap[cell.group!]!.add(key)) {
            clashes['group']!.add('${cell.group} clash at $key');
          }

          roomMap[cell.room ?? ''] ??= {};
          if (!roomMap[cell.room!]!.add(key)) {
            clashes['room']!.add('${cell.room} clash at $key');
          }
        });
      });
    });

    return clashes;
  }

  // ---------- PDF Export ----------
  Future<void> exportPDF() async {
    if (timetableResult == null) return;
    final pdf = pw.Document();

    timetableResult!.forEach((deptName, dayMap) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  deptName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['Day', ...periods],
                  data: [
                    for (var d in days)
                      [
                        d,
                        ...periods.map((p) {
                          final cell = dayMap[d]![p]!;
                          if (cell.isEmpty) return 'Free';
                          return '${cell.subject}\n${cell.teacher}\n${cell.group}\n${cell.room}';
                        }),
                      ],
                  ],
                  cellStyle: pw.TextStyle(fontSize: 10),
                  headerStyle: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );
    });

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        title: const Text(
          '📅 Timetable Generator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00BCD4),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.grey[400],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.business_center), text: 'Departments'),
            Tab(icon: Icon(Icons.play_circle_outline), text: 'Generate'),
            Tab(icon: Icon(Icons.calendar_view_month), text: 'Timetable'),
            Tab(icon: Icon(Icons.error_outline), text: 'Clashes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDepartmentsTab(),
          _buildGenerateTab(),
          _buildTimetableTab(),
          _buildClashesTab(),
        ],
      ),
    );
  }

  // ---------- Departments Tab ----------
  Widget _buildDepartmentsTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _deptCtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Department name',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00BCD4),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final name = _deptCtl.text.trim();
                  if (name.isEmpty) return;
                  _addDepartment(name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add Dept',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _roomCtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Room name',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00BCD4),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final r = _roomCtl.text.trim();
                  if (r.isEmpty) return;
                  setState(() {
                    rooms.add(RoomModel(name: r));
                    _roomCtl.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add Room',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: departments.length,
              itemBuilder: (ctx, idx) {
                final dept = departments[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: const Color(0xFF1F1F1F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ExpansionTile(
                    key: ValueKey(dept.name + idx.toString()),
                    textColor: Colors.white,
                    iconColor: const Color(0xFF00BCD4),
                    collapsedIconColor: Colors.grey[400],
                    title: Text(
                      dept.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sessions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00BCD4),
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFF00BCD4),
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Add Session',
                                    style: TextStyle(
                                      color: Color(0xFF00BCD4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () {
                                    _showAddSessionDialog(dept);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...dept.sessions.asMap().entries.map((e) {
                              final s = e.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF121212),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.subject,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${s.teacher} • ${s.group}',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          dept.sessions.removeAt(e.key);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(color: Colors.grey),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sections',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00BCD4),
                                    fontSize: 15,
                                  ),
                                ),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.group_add,
                                        color: Color(0xFF00BCD4),
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Add Section',
                                        style: TextStyle(
                                          color: Color(0xFF00BCD4),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onPressed: () {
                                        _showAddSectionDialog(dept);
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Remove',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onPressed: () {
                                        if (dept.groups.isNotEmpty) {
                                          setState(() {
                                            dept.groups.removeLast();
                                          });
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'No sections to remove',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: dept.groups
                                  .map(
                                    (g) => Chip(
                                      label: Text(
                                        g,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF2A2A2A),
                                      side: const BorderSide(
                                        color: Color(0xFF00BCD4),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rooms: ${rooms.map((r) => r.name).join(", ")}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[400],
                                fontSize: 12,
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

  void _showAddSessionDialog(DepartmentModel dept) {
    final _subj = TextEditingController();
    final _teacher = TextEditingController();
    final _group = TextEditingController();
    if (dept.groups.isNotEmpty) _group.text = dept.groups.first;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Session',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subj,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00BCD4), width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _teacher,
                decoration: InputDecoration(
                  labelText: 'Teacher',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00BCD4), width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _group,
                decoration: InputDecoration(
                  labelText: 'Group/Section',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00BCD4), width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final subj = _subj.text.trim();
                final teacher = _teacher.text.trim();
                final group = _group.text.trim();
                if (subj.isEmpty || teacher.isEmpty || group.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter subject, teacher and group'),
                    ),
                  );
                  return;
                }
                setState(() {
                  dept.sessions.add(
                    SessionInput(subject: subj, teacher: teacher, group: group),
                  );
                  if (!dept.groups.contains(group)) dept.groups.add(group);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddSectionDialog(DepartmentModel dept) {
    final _g = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Section',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: _g,
            decoration: InputDecoration(
              labelText: 'Section name (e.g., CS-A)',
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00BCD4), width: 2),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final val = _g.text.trim();
                if (val.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter section name')),
                  );
                  return;
                }
                setState(() {
                  if (!dept.groups.contains(val)) dept.groups.add(val);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Generate Tab ----------
  Widget _buildGenerateTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Card(
              elevation: 0,
              color: const Color(0xFF1F1F1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration Preview',
                      style: TextStyle(
                        color: Color(0xFF00BCD4),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          jsonEncode(_previewRequest()),
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Periods/day:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        min: 4,
                        max: 10,
                        divisions: 6,
                        value: periodsPerDay.toDouble(),
                        label: periodsPerDay.toString(),
                        activeColor: const Color(0xFF00BCD4),
                        inactiveColor: Colors.grey[700],
                        onChanged: (v) {
                          setState(() => periodsPerDay = v.toInt());
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00BCD4)),
                      ),
                      child: Text(
                        periodsPerDay.toString(),
                        style: const TextStyle(
                          color: Color(0xFF00BCD4),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating
                        ? null
                        : () {
                            runHybridSolver(
                              popSize: 50,
                              generations: 200,
                              mutationRate: 0.1,
                            );
                          },
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: const Text(
                      'Generate Timetable',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_status.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (_isGenerating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF00BCD4)),
                      ),
                    ),
                  if (_isGenerating) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: _isGenerating
                            ? const Color(0xFF00BCD4)
                            : Colors.greenAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _previewRequest() {
    return {
      'departments': departments.map((d) => d.toJson()).toList(),
      'rooms': rooms.map((r) => r.toJson()).toList(),
      'periodsPerDay': periodsPerDay,
    };
  }

  // ---------- Timetable Tab ----------
  Widget _buildTimetableTab() {
    if (timetableResult == null)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No timetable generated',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure departments and generate a timetable',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    return ListView(
      padding: const EdgeInsets.all(12),
      children: timetableResult!.entries.map((deptEntry) {
        final dayMap = deptEntry.value;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          color: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business_center,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      deptEntry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                      (_) => const Color(0xFF2A2A2A),
                    ),
                    dataRowColor: MaterialStateColor.resolveWith(
                      (_) => const Color(0xFF1F1F1F),
                    ),
                    columnSpacing: 16,
                    headingRowHeight: 48,
                    columns: [
                      const DataColumn(
                        label: Text(
                          'Day',
                          style: TextStyle(
                            color: Color(0xFF00BCD4),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...periods.map(
                        (p) => DataColumn(
                          label: Text(
                            p,
                            style: const TextStyle(
                              color: Color(0xFF00BCD4),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: days.map((day) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                day,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          ...periods.map((p) {
                            final cell = dayMap[day]![p]!;
                            return DataCell(
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _renderCellColor(cell),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: cell.isEmpty
                                        ? Colors.grey.withOpacity(0.2)
                                        : const Color(
                                            0xFF00BCD4,
                                          ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  cell.isEmpty
                                      ? 'Free'
                                      : '${cell.subject}\n${cell.teacher}\n${cell.group}\n${cell.room}',
                                  style: TextStyle(
                                    color: cell.isEmpty
                                        ? Colors.grey[500]
                                        : Colors.white,
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: exportPDF,
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    label: const Text(
                      'Export as PDF',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _renderCellColor(TimetableCell cell) {
    if (cell.isEmpty) return const Color(0xFF121212);
    final clashes = analyzeClashesDetailed();
    final key = '${cell.day}-${cell.period}';
    if (clashes['teacher']!.any((c) => c.contains(key)) ||
        clashes['group']!.any((c) => c.contains(key)) ||
        clashes['room']!.any((c) => c.contains(key))) {
      return const Color(0xFF8B1538);
    }
    return const Color(0xFF2A2A2A);
  }

  // ---------- Clashes Tab ----------
  Widget _buildClashesTab() {
    final clashes = analyzeClashesDetailed();
    if (clashes.values.every((list) => list.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No clashes found!',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Timetable is conflict-free',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: clashes.entries
          .where((e) => e.value.isNotEmpty)
          .map(
            (entry) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              color: const Color(0xFF1F1F1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${entry.key.toUpperCase()} Clashes',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value.length}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.redAccent, height: 1),
                    const SizedBox(height: 12),
                    ...entry.value.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.arrow_right,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ---------------- Models ----------------

class DepartmentModel {
  String name;
  List<String> groups;
  List<SessionInput> sessions = [];
  DepartmentModel({required this.name, required this.groups});

  Map<String, dynamic> toJson() => {
    'name': name,
    'groups': groups,
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };
}

class RoomModel {
  String name;
  RoomModel({required this.name});
  Map<String, dynamic> toJson() => {'name': name};
}

class SessionInput {
  String subject;
  String teacher;
  String group;
  SessionInput({
    required this.subject,
    required this.teacher,
    required this.group,
  });
  Map<String, dynamic> toJson() => {
    'subject': subject,
    'teacher': teacher,
    'group': group,
  };
}

class TimetableCell {
  String? subject;
  String? teacher;
  String? group;
  String? room;
  String day;
  String period;

  TimetableCell({
    required this.subject,
    required this.teacher,
    required this.group,
    required this.room,
    required this.day,
    required this.period,
  });

  bool get isEmpty =>
      subject == null && teacher == null && group == null && room == null;

  factory TimetableCell.empty({required String day, required String period}) {
    return TimetableCell(
      subject: null,
      teacher: null,
      group: null,
      room: null,
      day: day,
      period: period,
    );
  }
}
