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
  int periodsPerDay = 8;
  List<String> get periods => [for (int i = 1; i <= periodsPerDay; i++) 'P$i'];

  // Period timings: 8:00 AM start, 45 min per period
  String formatTime(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    String period = hours >= 12 ? 'PM' : 'AM';
    if (hours > 12) hours -= 12;
    if (hours == 0) hours = 12;
    return '$hours:${mins.toString().padLeft(2, '0')} $period';
  }

  String getPeriodTiming(int periodNum) {
    final startMinutes = _periodStartMinutes(periodNum);
    int endMinutes = startMinutes + 45;
    return '${formatTime(startMinutes)} - ${formatTime(endMinutes)}';
  }

  int _periodStartMinutes(int periodNum) {
    int startMinutes = 8 * 60; // 8:00 AM in minutes
    for (int i = 1; i < periodNum; i++) {
      startMinutes += 45; // Add period duration
    }
    return startMinutes;
  }

  List<Map<String, dynamic>> allowedBreakSlots() {
    // Generate 15-minute break slots between 9:30 AM and 10:15 AM
    final slots = <Map<String, dynamic>>[];
    final breakStartLimit = 9 * 60 + 30; // 9:30 AM in minutes
    final breakEndLimit = 10 * 60 + 15; // 10:15 AM in minutes

    int currentStart = breakStartLimit;
    while (currentStart + 15 <= breakEndLimit) {
      final end = currentStart + 15;
      slots.add({
        'key': '$currentStart-$end',
        'label': '${formatTime(currentStart)} - ${formatTime(end)}',
      });
      currentStart += 15; // Move to next 15-min slot
    }
    return slots;
  }

  List<Map<String, dynamic>> allowedLunchSlots() {
    // Generate 45-minute lunch slots between 11:15 AM and 1:00 PM
    final slots = <Map<String, dynamic>>[];
    final lunchStartLimit = 11 * 60 + 15; // 11:15 AM in minutes
    final lunchEndLimit = 13 * 60; // 1:00 PM in minutes

    int currentStart = lunchStartLimit;
    while (currentStart + 45 <= lunchEndLimit) {
      final end = currentStart + 45;
      slots.add({
        'key': '$currentStart-$end',
        'label': '${formatTime(currentStart)} - ${formatTime(end)}',
      });
      currentStart += 15; // Move to next slot (15-min intervals)
    }
    return slots;
  }

  String getBreakInfo(int periodNum) {
    if (periodNum == 3) return '\n☕ Break (15 min)';
    return '';
  }

  List<String> _allTeachers() {
    final set = <String>{};
    for (final d in departments) {
      for (final s in d.sessions) {
        set.add(s.teacher);
      }
    }
    return set.toList()..sort();
  }

  bool _isTeacherBlocked(String teacher, int periodNum) {
    // Check if the period overlaps with department's break or lunch time slot
    final periodStart = _periodStartMinutes(periodNum);
    final periodEnd = periodStart + 45;

    // Find which department this teacher belongs to
    DepartmentModel? teacherDept;
    for (final dept in departments) {
      if (dept.sessions.any((s) => s.teacher == teacher)) {
        teacherDept = dept;
        break;
      }
    }

    if (teacherDept == null) return false;

    final breakPref = teacherDept.breakTimeSlot;
    if (breakPref != null && breakPref.isNotEmpty) {
      final parts = breakPref.split('-');
      if (parts.length == 2) {
        final breakStart = int.parse(parts[0]);
        final breakEnd = int.parse(parts[1]);
        // Check if period overlaps with break slot
        if (!(periodEnd <= breakStart || periodStart >= breakEnd)) {
          return true; // Overlaps
        }
      }
    }

    final lunchPref = teacherDept.lunchTimeSlot;
    if (lunchPref != null && lunchPref.isNotEmpty) {
      final parts = lunchPref.split('-');
      if (parts.length == 2) {
        final lunchStart = int.parse(parts[0]);
        final lunchEnd = int.parse(parts[1]);
        // Check if period overlaps with lunch slot
        if (!(periodEnd <= lunchStart || periodStart >= lunchEnd)) {
          return true; // Overlaps
        }
      }
    }

    return false;
  }

  final List<DepartmentModel> departments = [];
  Map<String, Map<String, Map<String, TimetableCell>>>? timetableResult;

  bool _isGenerating = false;
  String _status = '';
  final TextEditingController _deptCtl = TextEditingController();
  late TabController _tabController;

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // ============================================================
    // SAMPLE DATA - DELETE THIS SECTION WHEN NOT NEEDED
    // This is example data from B.Tech CSE timetable
    // Delete everything between the START and END markers
    // ============================================================
    // START SAMPLE DATA

    // Add CSE Department with subjects from the timetable
    final cseDept = DepartmentModel(
      name: 'Computer Science Engineering',
      groups: ['CSE-A', 'CSE-B'],
    );

    // Add sessions based on the timetable image
    cseDept.sessions.addAll([
      SessionInput(
        subject: 'CTCD',
        teacher: 'Dr. Sivakumar',
        group: 'CSE-A',
        numberOfPeriods: 5,
      ),
      SessionInput(
        subject: 'IAIML',
        teacher: 'Dr. B. Sundurambai',
        group: 'CSE-A',
        numberOfPeriods: 4,
      ),
      SessionInput(
        subject: 'FM',
        teacher: 'Mr. C. Selvanganesan',
        group: 'CSE-A',
        numberOfPeriods: 3,
      ),
      SessionInput(
        subject: 'CN',
        teacher: 'Dr. N. Kirubakaran',
        group: 'CSE-A',
        numberOfPeriods: 4,
      ),
      SessionInput(
        subject: 'AJP',
        teacher: 'Mr. G. Senthil Kumar',
        group: 'CSE-A',
        numberOfPeriods: 5,
      ),
      SessionInput(
        subject: 'SE',
        teacher: 'Dr. Kouthai',
        group: 'CSE-A',
        numberOfPeriods: 3,
      ),

      // Lab sessions
      SessionInput(
        subject: 'CN Lab',
        teacher: 'bbb',
        group: 'CSE-A',
        numberOfPeriods: 2,
      ),
    ]);

    departments.add(cseDept);

    // Add Computer Engineering Department (CPE) - III Year VI Semester
    final cpeDept = DepartmentModel(
      name: 'Computer Engineering',
      groups: ['CPE-A'],
    );

    // Add sessions from the CPE timetable (aligned to the provided sheet)
    cpeDept.sessions.addAll([
      SessionInput(
        subject: 'SPM',
        teacher: 'Mr. Pabhu M',
        group: 'CPE-A',
        numberOfPeriods: 4,
      ), // Software Project Management
      SessionInput(
        subject: 'EIA',
        teacher: 'Mr. Abishek',
        group: 'CPE-A',
        numberOfPeriods: 3,
      ), // Environmental Impact Assessment
      SessionInput(
        subject: 'BS',
        teacher: 'Mr. Selvanganesan',
        group: 'CPE-A',
        numberOfPeriods: 3,
      ), // Business Strategy
      SessionInput(
        subject: 'DT',
        teacher: 'Ms. Mahalakshmi',
        group: 'CPE-A',
        numberOfPeriods: 4,
      ), // Design Thinking
      SessionInput(
        subject: 'CSM',
        teacher: 'Mr. Ravikumar A',
        group: 'CPE-A',
        numberOfPeriods: 5,
      ), // Cyber Security Management
      SessionInput(
        subject: 'BA',
        teacher: 'Mr. Arun',
        group: 'CPE-A',
        numberOfPeriods: 4,
      ), // Business Analytics
      SessionInput(
        subject: 'CCP',
        teacher: 'Ms. Vishali',
        group: 'CPE-A',
        numberOfPeriods: 3,
      ), // Core Course Project V
    ]);

    departments.add(cpeDept);

    // END SAMPLE DATA
    // ============================================================
    // To use your own data, delete everything between START and END markers above
    // ============================================================
  }

  @override
  void dispose() {
    _deptCtl.dispose();
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
      const int maxAttempts =
          20; // Retry fresh populations until clash-free or cap reached
      Map<String, Map<String, Map<String, TimetableCell>>>? bestOverall;
      int bestOverallFitness = 1 << 30;
      int attempt = 0;

      while (attempt < maxAttempts) {
        attempt++;
        // ---------- GA Population ----------
        List<Map<String, Map<String, Map<String, TimetableCell>>>> population =
            [];

        // Generate initial random population
        for (int i = 0; i < popSize; i++) {
          population.add(_generateRandomTimetable());
        }

        int currentGeneration = 0;

        while (currentGeneration < generations) {
          currentGeneration++;

          // ---------- Evaluate Fitness ----------
          population.sort((a, b) {
            int fitnessA = _calculateFitness(a);
            int fitnessB = _calculateFitness(b);
            return fitnessA.compareTo(
              fitnessB,
            ); // Lower fitness = fewer clashes
          });

          // ---------- Check Best Timetable ----------
          final best = population.first;
          final clashes = _analyzeClashes(best);
          final bestFitness = _calculateFitness(best);

          setState(() {
            _status =
                'Attempt $attempt | Generation $currentGeneration | Best fitness: $bestFitness | Teacher clashes: ${clashes['teacher']!.length}';
          });

          // Track global best across attempts
          if (bestFitness < bestOverallFitness) {
            bestOverallFitness = bestFitness;
            bestOverall = best;
          }

          if (_isClashFree(best)) {
            timetableResult = best;
            currentGeneration = generations; // exit inner loop
            break;
          }

          // ---------- Crossover & Mutation ----------
          List<Map<String, Map<String, Map<String, TimetableCell>>>>
          newPopulation = [];

          // Keep the top 10% as elite to preserve best solutions
          int eliteCount = (popSize * 0.1).ceil();
          newPopulation.addAll(population.take(eliteCount));

          // Generate the rest of the population
          while (newPopulation.length < popSize) {
            final parent1 = population[Random().nextInt(population.length)];
            final parent2 = population[Random().nextInt(population.length)];

            final child = _crossoverTimetable(parent1, parent2);
            _mutateTimetable(child, mutationRate);
            newPopulation.add(child);
          }

          population = newPopulation;

          await Future.delayed(const Duration(milliseconds: 10));
        }

        if (timetableResult != null && _isClashFree(timetableResult!)) {
          break; // achieved clash-free
        }

        // Early stop if perfect fitness found even if timetableResult not set
        if (bestOverallFitness == 0) {
          timetableResult = bestOverall;
          break;
        }
      }

      // ---------- Final Update ----------
      timetableResult ??=
          bestOverall; // fall back to best seen if clash-free not found

      setState(() {
        _isGenerating = false;
        _status = timetableResult != null && _isClashFree(timetableResult!)
            ? 'Timetable generation completed without teacher/group clashes.'
            : 'Best effort completed (minimized clashes).';
        _tabController.animateTo(2); // Show timetable
      });
    });
  }

  // ---------------- Helper Functions ----------------

  Map<String, Map<String, Map<String, TimetableCell>>>
  _generateRandomTimetable() {
    final Map<String, Map<String, Map<String, TimetableCell>>> result = {};

    // Track how many times each session has been used per department
    final Map<String, Map<SessionInput, int>> sessionUsageCount = {};

    for (var dept in departments) {
      result[dept.name] = {};
      sessionUsageCount[dept.name] = {};

      // Initialize usage count for all sessions
      for (var session in dept.sessions) {
        sessionUsageCount[dept.name]![session] = 0;
      }

      for (var day in days) {
        result[dept.name]![day] = {};
        for (int p = 0; p < periodsPerDay; p++) {
          // Session scheduling - filter sessions that haven't reached their period limit
          final availableSessions = dept.sessions.where((session) {
            final currentUsage = sessionUsageCount[dept.name]![session] ?? 0;
            return currentUsage < session.numberOfPeriods;
          }).toList();

          if (availableSessions.isNotEmpty) {
            final shuffled = [...availableSessions]..shuffle();
            SessionInput? chosen;

            // Find a session whose teacher/group is not already busy at this time
            for (final session in shuffled) {
              if (!_isTeacherBusyAtTime(
                    session.teacher,
                    day,
                    'P${p + 1}',
                    result,
                  ) &&
                  !_isGroupBusyAtTime(
                    session.group,
                    day,
                    'P${p + 1}',
                    result,
                  )) {
                chosen = session;
                break;
              }
            }

            // Only assign if we found an available teacher/group; otherwise leave empty
            if (chosen != null) {
              result[dept.name]![day]!['P${p + 1}'] = TimetableCell(
                subject: chosen.subject,
                teacher: chosen.teacher,
                group: chosen.group,
                room: null,
                day: day,
                period: 'P${p + 1}',
              );
              // Increment usage count
              sessionUsageCount[dept.name]![chosen] =
                  (sessionUsageCount[dept.name]![chosen] ?? 0) + 1;
            } else {
              result[dept.name]![day]!['P${p + 1}'] = TimetableCell.empty(
                day: day,
                period: 'P${p + 1}',
              );
            }
          } else {
            result[dept.name]![day]!['P${p + 1}'] = TimetableCell.empty(
              day: day,
              period: 'P${p + 1}',
            );
          }
        }
      }
    }
    return result;
  }

  bool _isDeptSlotBlocked(DepartmentModel dept, int periodNum) {
    final periodStart = _periodStartMinutes(periodNum);
    final periodEnd = periodStart + 45;

    if (dept.breakTimeSlot != null && dept.breakTimeSlot!.isNotEmpty) {
      final parts = dept.breakTimeSlot!.split('-');
      if (parts.length == 2) {
        final breakStart = int.parse(parts[0]);
        final breakEnd = int.parse(parts[1]);
        if (!(periodEnd <= breakStart || periodStart >= breakEnd)) {
          return true;
        }
      }
    }

    if (dept.lunchTimeSlot != null && dept.lunchTimeSlot!.isNotEmpty) {
      final parts = dept.lunchTimeSlot!.split('-');
      if (parts.length == 2) {
        final lunchStart = int.parse(parts[0]);
        final lunchEnd = int.parse(parts[1]);
        if (!(periodEnd <= lunchStart || periodStart >= lunchEnd)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isTeacherBusyAtTime(
    String teacher,
    String day,
    String period,
    Map<String, Map<String, Map<String, TimetableCell>>> timetable,
  ) {
    for (var deptMap in timetable.values) {
      final cell = deptMap[day]?[period];
      if (cell != null && !cell.isEmpty && cell.teacher == teacher) {
        return true;
      }
    }
    return false;
  }

  bool _isGroupBusyAtTime(
    String group,
    String day,
    String period,
    Map<String, Map<String, Map<String, TimetableCell>>> timetable,
  ) {
    for (var deptMap in timetable.values) {
      final cell = deptMap[day]?[period];
      if (cell != null && !cell.isEmpty && cell.group == group) {
        return true;
      }
    }
    return false;
  }

  int _calculateFitness(
    Map<String, Map<String, Map<String, TimetableCell>>> timetable,
  ) {
    final clashes = _analyzeClashes(timetable);
    // Heavy penalty for teacher/group clashes
    int score =
        (clashes['teacher']!.length * 100) + (clashes['group']!.length * 100);

    // Track period count mismatches
    int periodCountMismatches = 0;

    for (var dept in departments) {
      final deptTimetable = timetable[dept.name];
      if (deptTimetable == null) continue;

      // Count how many times each subject appears in the timetable
      final Map<String, int> subjectCounts = {};

      deptTimetable.forEach((day, periodMap) {
        periodMap.forEach((period, cell) {
          if (!cell.isEmpty &&
              cell.subject != '☕ BREAK' &&
              cell.subject != '🍽️ LUNCH') {
            subjectCounts[cell.subject!] =
                (subjectCounts[cell.subject!] ?? 0) + 1;
          }
        });
      });

      // Compare with required period counts
      for (var session in dept.sessions) {
        final actualCount = subjectCounts[session.subject] ?? 0;
        final requiredCount = session.numberOfPeriods;

        // Penalize deviation from required count (both over and under)
        periodCountMismatches += (actualCount - requiredCount).abs() * 50;
      }
    }

    score += periodCountMismatches;

    return score;
  }

  bool _isClashFree(
    Map<String, Map<String, Map<String, TimetableCell>>> timetable,
  ) {
    final clashes = _analyzeClashes(timetable);
    return clashes['teacher']!.isEmpty && clashes['group']!.isEmpty;
  }

  Map<String, List<String>> _analyzeClashes(
    Map<String, Map<String, Map<String, TimetableCell>>> timetable,
  ) {
    final Map<String, List<String>> clashes = {'teacher': [], 'group': []};

    // Check each day-period slot for conflicts across departments
    for (var day in days) {
      for (var period in periods) {
        final Map<String, String> teachersAtSlot = {}; // teacher -> dept
        final Map<String, String> groupsAtSlot = {}; // group -> dept

        timetable.forEach((deptName, dayMap) {
          final cell = dayMap[day]?[period];
          if (cell == null || cell.isEmpty) return;

          final teacher = cell.teacher ?? 'UNKNOWN_TEACHER';
          final group = cell.group ?? 'UNKNOWN_GROUP';

          // Check if this teacher is already assigned at this slot in another dept
          if (teachersAtSlot.containsKey(teacher)) {
            final otherDept = teachersAtSlot[teacher]!;
            clashes['teacher']!.add(
              'Teacher $teacher clash at $day-$period (in $deptName and $otherDept)',
            );
          } else {
            teachersAtSlot[teacher] = deptName;
          }

          // Check if this group is already assigned at this slot in another dept
          if (groupsAtSlot.containsKey(group)) {
            final otherDept = groupsAtSlot[group]!;
            clashes['group']!.add(
              'Group $group clash at $day-$period (in $deptName and $otherDept)',
            );
          } else {
            groupsAtSlot[group] = deptName;
          }
        });
      }
    }

    return clashes;
  }

  Map<String, Map<String, Map<String, TimetableCell>>> _crossoverTimetable(
    Map<String, Map<String, Map<String, TimetableCell>>> parent1,
    Map<String, Map<String, Map<String, TimetableCell>>> parent2,
  ) {
    final child = <String, Map<String, Map<String, TimetableCell>>>{};
    for (var dept in departments) {
      child[dept.name] = {};
      for (var day in days) {
        child[dept.name]![day] = {};
        for (int p = 0; p < periodsPerDay; p++) {
          child[dept.name]![day]!['P${p + 1}'] = (Random().nextBool()
              ? parent1
              : parent2)[dept.name]![day]!['P${p + 1}']!;
        }
      }
    }
    return child;
  }

  void _mutateTimetable(
    Map<String, Map<String, Map<String, TimetableCell>>> timetable,
    double rate,
  ) {
    for (var dept in departments) {
      // Track current usage counts for this department
      final Map<SessionInput, int> sessionUsageCount = {};
      for (var session in dept.sessions) {
        sessionUsageCount[session] = 0;
      }

      // Count existing sessions
      for (var day in days) {
        for (int p = 0; p < periodsPerDay; p++) {
          final cell = timetable[dept.name]?[day]?['P${p + 1}'];
          if (cell != null && !cell.isEmpty) {
            // Find matching session
            for (var session in dept.sessions) {
              if (session.subject == cell.subject &&
                  session.teacher == cell.teacher &&
                  session.group == cell.group) {
                sessionUsageCount[session] =
                    (sessionUsageCount[session] ?? 0) + 1;
                break;
              }
            }
          }
        }
      }

      for (var day in days) {
        for (int p = 0; p < periodsPerDay; p++) {
          if (Random().nextDouble() < rate) {
            final periodNum = p + 1;
            final existing = timetable[dept.name]?[day]?['P$periodNum'];

            // Decrement count if replacing existing session
            if (existing != null && !existing.isEmpty) {
              for (var session in dept.sessions) {
                if (session.subject == existing.subject &&
                    session.teacher == existing.teacher &&
                    session.group == existing.group) {
                  sessionUsageCount[session] =
                      ((sessionUsageCount[session] ?? 0) - 1).clamp(0, 999);
                  break;
                }
              }
            }

            // Filter sessions that haven't reached their period limit
            final availableSessions = dept.sessions.where((session) {
              final currentUsage = sessionUsageCount[session] ?? 0;
              return currentUsage < session.numberOfPeriods;
            }).toList();

            if (availableSessions.isNotEmpty) {
              final shuffled = [...availableSessions]..shuffle();
              SessionInput? chosen;

              // Find a session whose teacher/group is not already busy at this time
              for (final s in shuffled) {
                if (!_isTeacherBusyAtTime(
                      s.teacher,
                      day,
                      'P$periodNum',
                      timetable,
                    ) &&
                    !_isGroupBusyAtTime(
                      s.group,
                      day,
                      'P$periodNum',
                      timetable,
                    )) {
                  chosen = s;
                  break;
                }
              }

              if (chosen != null) {
                timetable[dept.name]![day]!['P${p + 1}'] = TimetableCell(
                  subject: chosen.subject,
                  teacher: chosen.teacher,
                  group: chosen.group,
                  room: null,
                  day: day,
                  period: 'P${p + 1}',
                );
                // Increment usage count
                sessionUsageCount[chosen] =
                    (sessionUsageCount[chosen] ?? 0) + 1;
              } else {
                // Set to empty if no suitable session found
                timetable[dept.name]![day]!['P${p + 1}'] = TimetableCell.empty(
                  day: day,
                  period: 'P${p + 1}',
                );
              }
            } else {
              // All sessions are at their limit, leave empty
              timetable[dept.name]![day]!['P${p + 1}'] = TimetableCell.empty(
                day: day,
                period: 'P${p + 1}',
              );
            }
          }
        }
      }
    }
  }

  void _repairTimetable(
    Map<String, Map<String, Map<String, TimetableCell>>> timetable,
  ) {
    // Simple repair: detect clashes and randomly reassign one of the conflicting cells
    final clashes = _analyzeClashes(timetable);

    if (clashes['teacher']!.isEmpty && clashes['group']!.isEmpty) {
      return; // No clashes to repair
    }

    // Collect all clashing slots
    Set<String> clashingSlots = {};
    for (var clashList in clashes.values) {
      for (var clash in clashList) {
        // Extract day-period from clash message
        final match = RegExp(r'at ([^\s]+)').firstMatch(clash);
        if (match != null) {
          clashingSlots.add(match.group(1)!);
        }
      }
    }

    // Try to fix clashes by swapping with random free slots
    for (var slotKey in clashingSlots) {
      final parts = slotKey.split('-');
      if (parts.length != 2) continue;
      final day = parts[0];
      final period = parts[1];

      // Find cells in this clashing slot
      for (var deptName in timetable.keys) {
        if (timetable[deptName]![day]?[period] != null) {
          final cell = timetable[deptName]![day]![period]!;
          if (!cell.isEmpty) {
            // Try to swap with a random other slot
            final randomDay = days[Random().nextInt(days.length)];
            final randomPeriod = 'P${Random().nextInt(periodsPerDay) + 1}';

            final targetCell = timetable[deptName]![randomDay]![randomPeriod]!;

            // Simple swap
            timetable[deptName]![randomDay]![randomPeriod] = cell.copyWith(
              day: randomDay,
              period: randomPeriod,
            );
            timetable[deptName]![day]![period] = targetCell.copyWith(
              day: day,
              period: period,
            );
          }
        }
      }
    }
  }

  // ---------- Private helper to check if teacher is busy ----------
  bool _isTeacherBusy(
    String teacher,
    String day,
    String period,
    Map<String, Map<String, Map<String, TimetableCell>>> timetable,
  ) {
    for (var deptMap in timetable.values) {
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

          final teacher = cell.teacher ?? 'UNKNOWN_TEACHER';
          final group = cell.group ?? 'UNKNOWN_GROUP';
          final room = cell.room ?? 'UNKNOWN_ROOM';

          // ---------- Teacher Clash ----------
          teacherMap[teacher] ??= <String>{};
          if (!teacherMap[teacher]!.add(key)) {
            clashes['teacher']!.add('Teacher $teacher clash at $key');
          }

          // ---------- Group Clash ----------
          groupMap[group] ??= <String>{};
          if (!groupMap[group]!.add(key)) {
            clashes['group']!.add('Group $group clash at $key');
          }

          // ---------- Room Clash ----------
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
                          return '${cell.subject}\n${cell.teacher}\n${cell.group}';
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
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          departments.removeAt(idx);
                        });
                      },
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
                                        Icons.edit_outlined,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _showAddSessionDialog(
                                          dept,
                                          editIndex: e.key,
                                          existing: s,
                                        );
                                      },
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

  void _showAddSessionDialog(
    DepartmentModel dept, {
    int? editIndex,
    SessionInput? existing,
  }) {
    final _subj = TextEditingController(text: existing?.subject ?? '');
    final _teacher = TextEditingController(text: existing?.teacher ?? '');
    final _group = TextEditingController(
      text:
          existing?.group ?? (dept.groups.isNotEmpty ? dept.groups.first : ''),
    );
    final _periods = TextEditingController(
      text: existing?.numberOfPeriods.toString() ?? '1',
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            editIndex == null ? 'Add Session' : 'Edit Session',
            style: const TextStyle(
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
              const SizedBox(height: 16),
              TextField(
                controller: _periods,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Periods',
                  helperText: 'How many periods per week for this subject',
                  helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
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
                final periodsText = _periods.text.trim();

                if (subj.isEmpty ||
                    teacher.isEmpty ||
                    group.isEmpty ||
                    periodsText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }

                final numberOfPeriods = int.tryParse(periodsText);
                if (numberOfPeriods == null || numberOfPeriods < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Number of periods must be a positive integer',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  final session = SessionInput(
                    subject: subj,
                    teacher: teacher,
                    group: group,
                    numberOfPeriods: numberOfPeriods,
                  );
                  if (editIndex == null) {
                    dept.sessions.add(session);
                  } else {
                    dept.sessions[editIndex] = session;
                  }
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
                'Save',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
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
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                  ),
                ],
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
                        (period) => DataColumn(
                          label: Text(
                            period,
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
                                      : '${cell.subject}\n${cell.teacher}\n${cell.group}',
                                  style: TextStyle(
                                    color: cell.isEmpty
                                        ? Colors.grey[500]
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
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
  String? breakTimeSlot; // Stores "startMin-endMin" for department break
  String? lunchTimeSlot; // Stores "startMin-endMin" for department lunch

  DepartmentModel({required this.name, required this.groups});

  Map<String, dynamic> toJson() => {
    'name': name,
    'groups': groups,
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'breakTimeSlot': breakTimeSlot,
    'lunchTimeSlot': lunchTimeSlot,
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
  int numberOfPeriods;
  SessionInput({
    required this.subject,
    required this.teacher,
    required this.group,
    this.numberOfPeriods = 1,
  });
  Map<String, dynamic> toJson() => {
    'subject': subject,
    'teacher': teacher,
    'group': group,
    'numberOfPeriods': numberOfPeriods,
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

  TimetableCell copyWith({
    String? subject,
    String? teacher,
    String? group,
    String? room,
    String? day,
    String? period,
  }) {
    return TimetableCell(
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      group: group ?? this.group,
      room: room ?? this.room,
      day: day ?? this.day,
      period: period ?? this.period,
    );
  }
}
