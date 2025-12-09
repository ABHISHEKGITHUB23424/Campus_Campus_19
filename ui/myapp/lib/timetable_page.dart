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
    String short = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').join();
    if (short.isEmpty) short = name.trim().substring(0, min(2, name.trim().length));
    short = short.toUpperCase();
    final defaultSection = '$short-A';
    setState(() {
      departments.add(DepartmentModel(name: name.trim(), groups: [defaultSection]));
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
                .where((s) => !isTeacherBusy(s.teacher, day, 'P${p + 1}', result))
                .toList();

            if (availableSessions.isNotEmpty) {
              final s = availableSessions[Random().nextInt(availableSessions.length)];
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
              result[dept.name]![day]!['P${p + 1}'] =
                  TimetableCell.empty(day: day, period: 'P${p + 1}');
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
bool isTeacherBusy(String teacher, String day, String period,
    Map<String, Map<String, Map<String, TimetableCell>>> currentResult) {
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
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(children: [
              pw.Text(deptName,
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal)),
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
                        })
                      ]
                  ],
                  cellStyle: pw.TextStyle(fontSize: 10),
                  headerStyle: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal),
                  cellAlignment: pw.Alignment.centerLeft),
            ]);
          }));
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
        title: const Text('Generate Student TimeTable'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Departments'),
            Tab(icon: Icon(Icons.play_arrow), text: 'Generate'),
            Tab(icon: Icon(Icons.grid_on), text: 'Timetable'),
            Tab(icon: Icon(Icons.warning), text: 'Clashes'),
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
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _deptCtl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  hintText: 'Department name', hintStyle: TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final name = _deptCtl.text.trim();
              if (name.isEmpty) return;
              _addDepartment(name);
            },
            child: const Text('Add Dept'),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _roomCtl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  hintText: 'Room name', hintStyle: TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final r = _roomCtl.text.trim();
              if (r.isEmpty) return;
              setState(() {
                rooms.add(RoomModel(name: r));
                _roomCtl.clear();
              });
            },
            child: const Text('Add Room'),
          ),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: departments.length,
            itemBuilder: (ctx, idx) {
              final dept = departments[idx];
              return Card(
                color: const Color(0xFF1E1E1E),
                child: ExpansionTile(
                  key: ValueKey(dept.name + idx.toString()),
                  textColor: Colors.white,
                  iconColor: Colors.tealAccent,
                  title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sessions',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: Colors.tealAccent)),
                            TextButton.icon(
                              icon: const Icon(Icons.add, color: Colors.tealAccent),
                              label: const Text('Add Session',
                                  style: TextStyle(color: Colors.tealAccent)),
                              onPressed: () {
                                _showAddSessionDialog(dept);
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...dept.sessions.asMap().entries.map((e) {
                          final s = e.value;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('${s.subject}', style: const TextStyle(color: Colors.white)),
                            subtitle: Text('${s.teacher} • ${s.group}',
                                style: const TextStyle(color: Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  dept.sessions.removeAt(e.key);
                                });
                              },
                            ),
                          );
                        }).toList(),
                        const Divider(color: Colors.grey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sections',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: Colors.tealAccent)),
                            Row(children: [
                              TextButton.icon(
                                icon: const Icon(Icons.group_add, color: Colors.tealAccent),
                                label: const Text('Add Section',
                                    style: TextStyle(color: Colors.tealAccent)),
                                onPressed: () {
                                  _showAddSectionDialog(dept);
                                },
                              ),
                              const SizedBox(width: 6),
                              TextButton.icon(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                label: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
                                onPressed: () {
                                  if (dept.groups.isNotEmpty) {
                                    setState(() {
                                      dept.groups.removeLast();
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No sections to remove')));
                                  }
                                },
                              ),
                            ])
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: dept.groups
                              .map((g) => Chip(
                                    label: Text(g, style: const TextStyle(color: Colors.white)),
                                    backgroundColor: const Color(0xFF2A2A2A),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Text('Rooms: ${rooms.map((r) => r.name).join(", ")}',
                            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                      ]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ]),
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
            backgroundColor: const Color(0xFF0B2430),
            title: const Text('Add Session', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _subj,
                  decoration: const InputDecoration(labelText: 'Subject', labelStyle: TextStyle(color: Colors.white70)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _teacher,
                  decoration: const InputDecoration(labelText: 'Teacher', labelStyle: TextStyle(color: Colors.white70)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _group,
                  decoration: const InputDecoration(labelText: 'Group/Section', labelStyle: TextStyle(color: Colors.white70)),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              ),
              TextButton(
                onPressed: () {
                  final subj = _subj.text.trim();
                  final teacher = _teacher.text.trim();
                  final group = _group.text.trim();
                  if (subj.isEmpty || teacher.isEmpty || group.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter subject, teacher and group')));
                    return;
                  }
                  setState(() {
                    dept.sessions.add(SessionInput(subject: subj, teacher: teacher, group: group));
                    if (!dept.groups.contains(group)) dept.groups.add(group);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add', style: TextStyle(color: Colors.greenAccent)),
              ),
            ],
          );
        });
  }

  void _showAddSectionDialog(DepartmentModel dept) {
    final _g = TextEditingController();
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0B2430),
            title: const Text('Add Section', style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: _g,
              decoration: const InputDecoration(labelText: 'Section name (e.g., CS-A)', labelStyle: TextStyle(color: Colors.white70)),
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.redAccent))),
              TextButton(
                  onPressed: () {
                    final val = _g.text.trim();
                    if (val.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter section name')));
                      return;
                    }
                    setState(() {
                      if (!dept.groups.contains(val)) dept.groups.add(val);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Add', style: TextStyle(color: Colors.greenAccent))),
            ],
          );
        });
  }

  // ---------- Generate Tab ----------
  Widget _buildGenerateTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Expanded(
          child: Card(
            color: const Color(0xFF1E1E1E),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                jsonEncode(_previewRequest()),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        Row(
          children: [
            const Text('Periods/day:', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                min: 4,
                max: 10,
                divisions: 6,
                value: periodsPerDay.toDouble(),
                label: periodsPerDay.toString(),
                onChanged: (v) {
                  setState(() => periodsPerDay = v.toInt());
                },
              ),
            ),
            ElevatedButton(
              onPressed: _isGenerating
                  ? null
                  : () {
                      runHybridSolver(popSize: 50, generations: 200, mutationRate: 0.1);
                    },
              child: const Text('Generate Timetable'),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(_status, style: const TextStyle(color: Colors.tealAccent)),
      ]),
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
    if (timetableResult == null) return const Center(child: Text('No timetable generated', style: TextStyle(color: Colors.white)));
    return ListView(
      padding: const EdgeInsets.all(12),
      children: timetableResult!.entries.map((deptEntry) {
        final dayMap = deptEntry.value;
        return Card(
          color: const Color(0xFF1E1E1E),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deptEntry.key,
                    style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith((_) => const Color(0xFF2A2A2A)),
                    columnSpacing: 12,
                    columns: [
                      const DataColumn(label: Text('Day', style: TextStyle(color: Colors.white))),
                      ...periods.map((p) => DataColumn(label: Text(p, style: const TextStyle(color: Colors.white)))),
                    ],
                    rows: days.map((day) {
                      return DataRow(
                        cells: [
                          DataCell(Text(day, style: const TextStyle(color: Colors.white))),
                          ...periods.map((p) {
                            final cell = dayMap[day]![p]!;
                            return DataCell(Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _renderCellColor(cell),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cell.isEmpty
                                    ? 'Free'
                                    : '${cell.subject}\n${cell.teacher}\n${cell.group}\n${cell.room}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ));
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                    onPressed: exportPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF')),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _renderCellColor(TimetableCell cell) {
    if (cell.isEmpty) return const Color(0xFF1E1E1E);
    final clashes = analyzeClashesDetailed();
    final key = '${cell.day}-${cell.period}';
    if (clashes['teacher']!.any((c) => c.contains(key)) ||
        clashes['group']!.any((c) => c.contains(key)) ||
        clashes['room']!.any((c) => c.contains(key))) {
      return Colors.redAccent.shade700;
    }
    return const Color(0xFF2A2A2A);
  }

  // ---------- Clashes Tab ----------
  Widget _buildClashesTab() {
    final clashes = analyzeClashesDetailed();
    if (clashes.values.every((list) => list.isEmpty)) {
      return const Center(child: Text('No clashes found!', style: TextStyle(color: Colors.greenAccent)));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: clashes.entries
          .where((e) => e.value.isNotEmpty)
          .map((entry) => Card(
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key.toUpperCase()} Clashes',
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ...entry.value.map((c) => Text(c, style: const TextStyle(color: Colors.white70))),
                    ],
                  ),
                ),
              ))
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
  SessionInput({required this.subject, required this.teacher, required this.group});
  Map<String, dynamic> toJson() => {'subject': subject, 'teacher': teacher, 'group': group};
}

class TimetableCell {
  String? subject;
  String? teacher;
  String? group;
  String? room;
  String day;
  String period;

  TimetableCell(
      {required this.subject,
      required this.teacher,
      required this.group,
      required this.room,
      required this.day,
      required this.period});

  bool get isEmpty => subject == null && teacher == null && group == null && room == null;

  factory TimetableCell.empty({required String day, required String period}) {
    return TimetableCell(subject: null, teacher: null, group: null, room: null, day: day, period: period);
  }
}
