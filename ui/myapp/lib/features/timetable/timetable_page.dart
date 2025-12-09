import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'services/timetable_service.dart';

/// Timetable page integrated with backend `TimetableService`.
class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final List<DepartmentModel> departments = [];
  final List<String> teachers = [];
  int periodsPerDay = 8;
  Map<String, dynamic>? timetableResult;

  late TimetableService _timetableService;

  List<String> get timeslots => [
    for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'])
      for (int p = 1; p <= periodsPerDay; p++) '${d}-P$p',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _timetableService = TimetableService(ApiClient());

    // sample departments
    final d1 = DepartmentModel(name: 'Computer Science')
      ..groups.addAll(['CS-A', 'CS-B'])
      ..staff.addAll(['Alice', 'Bob'])
      ..sessions.addAll([
        SessionInput(
          subject: 'Mathematics',
          teacher: 'Alice',
          group: 'CS-A',
          hours: 4,
        ),
        SessionInput(
          subject: 'Programming',
          teacher: 'Bob',
          group: 'CS-B',
          hours: 3,
        ),
      ]);

    final d2 = DepartmentModel(name: 'Mechanical')
      ..groups.add('ME-A')
      ..staff.add('Charlie')
      ..sessions.add(
        SessionInput(
          subject: 'Thermodynamics',
          teacher: 'Charlie',
          group: 'ME-A',
          hours: 4,
        ),
      );

    departments.addAll([d1, d2]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, dynamic> buildRequestBody() {
    return {
      'departments': departments.map((d) => d.toJson()).toList(),
      'timeslots': timeslots,
      'periods_per_day': periodsPerDay,
    };
  }

  Future<void> callGenerateApi() async {
    final body = buildRequestBody();
    setState(() => timetableResult = null);
    try {
      final resp = await _timetableService.generateTimetable(
        departments: List<Map<String, dynamic>>.from(body['departments']),
        timeslots: List<dynamic>.from(body['timeslots']),
      );

      setState(() {
        if (resp is Map<String, dynamic>) {
          timetableResult = resp;
        } else if (resp is Map) {
          timetableResult = Map<String, dynamic>.from(resp);
        } else {
          timetableResult = {'result': resp.toString()};
        }
        _tabController.animateTo(2);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network / server error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Timetable'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Departments', icon: Icon(Icons.business)),
            Tab(text: 'Generate', icon: Icon(Icons.play_arrow)),
            Tab(text: 'Timetable', icon: Icon(Icons.grid_on)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DepartmentsTab(
            departments: departments,
            teachers: teachers,
            onUpdated: () => setState(() {}),
          ),
          GenerateTab(
            onGenerate: callGenerateApi,
            previewBody: buildRequestBody,
          ),
          TimetableTab(timetableResult: timetableResult),
        ],
      ),
    );
  }
}

// -----------------------------
// Models
// -----------------------------
class SessionInput {
  String subject;
  String teacher;
  String group;
  int hours;

  SessionInput({
    required this.subject,
    required this.teacher,
    required this.group,
    this.hours = 1,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'teacher': teacher,
    'group': group,
    'hours': hours,
  };
}

class DepartmentModel {
  String name;
  List<String> groups;
  List<SessionInput> sessions;
  List<String> staff;

  DepartmentModel({required this.name})
    : groups = [],
      sessions = [],
      staff = [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'groups': groups,
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'staff': staff.isEmpty ? null : staff,
  };
}

// -----------------------------
// Departments Tab
// -----------------------------
class DepartmentsTab extends StatefulWidget {
  final List<DepartmentModel> departments;
  final List<String> teachers;
  final VoidCallback onUpdated;

  const DepartmentsTab({
    Key? key,
    required this.departments,
    required this.teachers,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<DepartmentsTab> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<DepartmentsTab> {
  final TextEditingController deptCtl = TextEditingController();
  final Map<int, TextEditingController> _subjectCtrls = {};
  final Map<int, TextEditingController> _groupCtrls = {};
  final Map<int, TextEditingController> _hoursCtrls = {};
  final Map<int, String> _selectedTeacher = {};

  @override
  void dispose() {
    deptCtl.dispose();
    for (final c in _subjectCtrls.values) c.dispose();
    for (final c in _groupCtrls.values) c.dispose();
    for (final c in _hoursCtrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: deptCtl,
                  decoration: const InputDecoration(
                    hintText: 'Department name',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = deptCtl.text.trim();
                  if (name.isEmpty) return;
                  widget.departments.add(DepartmentModel(name: name));
                  deptCtl.clear();
                  widget.onUpdated();
                  setState(() {});
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: widget.departments.length,
              itemBuilder: (ctx, idx) {
                final dept = widget.departments[idx];

                _subjectCtrls.putIfAbsent(idx, () => TextEditingController());
                _groupCtrls.putIfAbsent(idx, () => TextEditingController());
                _hoursCtrls.putIfAbsent(
                  idx,
                  () => TextEditingController(text: '1'),
                );
                _selectedTeacher.putIfAbsent(
                  idx,
                  () => (dept.staff.isNotEmpty ? dept.staff.first : ''),
                );

                return Card(
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dept.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Delete department',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: ctx,
                              builder: (dctx) => AlertDialog(
                                title: const Text('Delete department'),
                                content: Text(
                                  'Delete department "${dept.name}"? This will remove its sessions and staff.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(dctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              for (final c in _subjectCtrls.values) {
                                try {
                                  c.dispose();
                                } catch (_) {}
                              }
                              for (final c in _groupCtrls.values) {
                                try {
                                  c.dispose();
                                } catch (_) {}
                              }
                              for (final c in _hoursCtrls.values) {
                                try {
                                  c.dispose();
                                } catch (_) {}
                              }
                              _subjectCtrls.clear();
                              _groupCtrls.clear();
                              _hoursCtrls.clear();
                              _selectedTeacher.clear();

                              widget.departments.removeAt(idx);
                              widget.onUpdated();
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sessions:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ...dept.sessions.asMap().entries.map((entry) {
                              final sIdx = entry.key;
                              final s = entry.value;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${s.subject} (${s.hours} periods)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text('${s.teacher} • ${s.group}'),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    dept.sessions.removeAt(sIdx);
                                    widget.onUpdated();
                                    setState(() {});
                                  },
                                ),
                              );
                            }).toList(),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Add Session',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _subjectCtrls[idx],
                              decoration: const InputDecoration(
                                hintText: 'Subject',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: dept.staff.isNotEmpty
                                      ? DropdownButtonFormField<String>(
                                          value: _selectedTeacher[idx],
                                          items: dept.staff
                                              .map(
                                                (t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) => setState(
                                            () =>
                                                _selectedTeacher[idx] = v ?? '',
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'Teacher',
                                          ),
                                        )
                                      : TextField(
                                          controller: _groupCtrls[idx],
                                          decoration: const InputDecoration(
                                            hintText: 'Teacher',
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _groupCtrls[idx],
                                    decoration: const InputDecoration(
                                      hintText: 'Group',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: TextField(
                                    controller: _hoursCtrls[idx],
                                    decoration: const InputDecoration(
                                      hintText: 'Periods (1-8)',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final subject = _subjectCtrls[idx]!.text
                                        .trim();
                                    final teacher = dept.staff.isNotEmpty
                                        ? (_selectedTeacher[idx] ?? '')
                                        : _groupCtrls[idx]!.text.trim();
                                    final group = _groupCtrls[idx]!.text.trim();
                                    final hoursText = _hoursCtrls[idx]!.text
                                        .trim();
                                    final hours = int.tryParse(hoursText) ?? 1;
                                    if (subject.isEmpty)
                                      return _showLocalSnack(
                                        ctx: ctx,
                                        msg: 'Enter subject',
                                      );
                                    if (teacher.isEmpty)
                                      return _showLocalSnack(
                                        ctx: ctx,
                                        msg: 'Enter/select teacher',
                                      );
                                    if (group.isEmpty)
                                      return _showLocalSnack(
                                        ctx: ctx,
                                        msg: 'Enter group',
                                      );
                                    if (hours < 1 || hours > 8)
                                      return _showLocalSnack(
                                        ctx: ctx,
                                        msg: 'Periods must be between 1 and 8',
                                      );

                                    dept.sessions.add(
                                      SessionInput(
                                        subject: subject,
                                        teacher: teacher,
                                        group: group,
                                        hours: hours,
                                      ),
                                    );
                                    _subjectCtrls[idx]!.clear();
                                    _groupCtrls[idx]!.clear();
                                    _hoursCtrls[idx]!.text = '1';
                                    widget.onUpdated();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Session'),
                                ),
                              ],
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

  void _showLocalSnack({required BuildContext ctx, required String msg}) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// -----------------------------
// Generate Tab
// -----------------------------
class GenerateTab extends StatelessWidget {
  final VoidCallback onGenerate;
  final Map<String, dynamic> Function() previewBody;

  const GenerateTab({
    Key? key,
    required this.onGenerate,
    required this.previewBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final preview = const JsonEncoder.withIndent('  ').convert(previewBody());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(preview),
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Generate Timetable'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------
// Timetable Tab
// -----------------------------
class TimetableTab extends StatelessWidget {
  final Map<String, dynamic>? timetableResult;
  const TimetableTab({Key? key, required this.timetableResult})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timetableResult == null)
      return const Center(child: Text('No timetable generated yet.'));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: timetableResult!.entries.map((deptEntry) {
        final deptName = deptEntry.key;
        final daysMap = deptEntry.value as Map<String, dynamic>;

        final computedMax = daysMap.values
            .map((d) => (d as Map<String, dynamic>).length)
            .fold<int>(0, (prev, cur) => cur > prev ? cur : prev);
        final maxCols = math.min(computedMax, 8);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deptName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Day',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          for (int c = 0; c < maxCols; c++)
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'P${c + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      for (final dayEntry in daysMap.entries)
                        () {
                          final day = dayEntry.key;
                          final sessions =
                              dayEntry.value as Map<String, dynamic>;
                          final entries = sessions.entries.toList();
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              for (int c = 0; c < maxCols; c++)
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: c < entries.length
                                      ? _buildSessionCell(
                                          entries[c].key,
                                          entries[c].value,
                                        )
                                      : const Text('-'),
                                ),
                            ],
                          );
                        }(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionCell(Object key, Object? value) {
    try {
      final info = value as Map<String, dynamic>;
      final subject = info['subject'] ?? '';
      final teacher = info['teacher'] ?? '';
      final group = info['group'] ?? '';
      final time = info['time'] ?? '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            teacher.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            group.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (time != null)
            Text(
              time.toString(),
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
            ),
        ],
      );
    } catch (_) {
      return Text(value?.toString() ?? '');
    }
  }

  Widget _buildLabCell(Object key, Object? value) {
    try {
      final info = value as Map<String, dynamic>;
      final teachers = (info['teacher'] ?? '').toString();
      final subject = info['subject'] ?? '';
      final group = info['group'] ?? '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LAB',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          if (subject != null)
            Text(
              subject.toString(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 4),
          Text(
            teachers.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            group.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    } catch (_) {
      return Text(value?.toString() ?? 'LAB');
    }
  }
}
