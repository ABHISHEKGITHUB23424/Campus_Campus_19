import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../utils/formatting.dart';
import '../controllers/student_controller.dart';
import '../data/models/attendance_record.dart';
import '../controllers/attendance_controller.dart';

/// Student attendance report page showing individual student attendance
class StudentReportPage extends ConsumerStatefulWidget {
  const StudentReportPage({super.key});

  @override
  ConsumerState<StudentReportPage> createState() => _StudentReportPageState();
}

class _StudentReportPageState extends ConsumerState<StudentReportPage> {
  int? selectedStudentId;
  String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studentControllerProvider.notifier).loadAllStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Student Report')),
      body: Column(
        children: [
          // Filters
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                // Student Dropdown
                DropdownButtonFormField<int>(
                  value: selectedStudentId,
                  decoration: const InputDecoration(
                    labelText: 'Select Student',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: studentState.students.map((student) {
                    return DropdownMenuItem(
                      value: student.id,
                      child: Text('${student.name} (${student.registerNo})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedStudentId = value);
                  },
                ),
                const SizedBox(height: 16),

                // Month Picker
                InkWell(
                  onTap: () => _selectMonth(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select Month',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    child: Text(
                      DateFormat(
                        'MMMM yyyy',
                      ).format(DateTime.parse('$selectedMonth-01')),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Attendance Report
          Expanded(
            child: selectedStudentId == null
                ? Center(
                    child: Text(
                      'Select a student to view report',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.neutral.withOpacity(0.7),
                      ),
                    ),
                  )
                : _buildAttendanceReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceReport() {
    final attendanceRecordsAsync = ref.watch(
      studentAttendanceProvider('${selectedStudentId!}|$selectedMonth'),
    );

    return attendanceRecordsAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: AppTheme.neutral.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No attendance records found',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.neutral.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for ${DateFormat('MMMM yyyy').format(DateTime.parse('$selectedMonth-01'))}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.neutral.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate statistics
        final totalDays = records.length;
        final presentDays = records.where((r) => r.isPresent).length;
        final absentDays = records.where((r) => r.isAbsent).length;
        final lateDays = records.where((r) => r.isLate).length;
        final attendancePercentage = totalDays > 0
            ? (presentDays / totalDays) * 100
            : 0.0;

        return Column(
          children: [
            // Summary Card
            _buildSummaryCard(
              totalDays,
              presentDays,
              absentDays,
              lateDays,
              attendancePercentage,
            ),

            const SizedBox(height: 16),

            // Records List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _buildRecordTile(record);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: LoadingIndicator(message: 'Loading attendance report...'),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.error.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading report',
                style: TextStyle(fontSize: 16, color: AppTheme.error),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.neutral.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    int totalDays,
    int presentDays,
    int absentDays,
    int lateDays,
    double percentage,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDark,
            AppTheme.primaryDark.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Percentage Circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.white.withOpacity(0.1),
              border: Border.all(color: AppTheme.accentCyan, width: 4),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const Text(
                    'Attendance',
                    style: TextStyle(fontSize: 12, color: AppTheme.accentCyan),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Total', totalDays.toString(), AppTheme.white),
              _buildStatColumn(
                'Present',
                presentDays.toString(),
                AppTheme.success,
              ),
              _buildStatColumn('Absent', absentDays.toString(), AppTheme.error),
              if (lateDays > 0)
                _buildStatColumn('Late', lateDays.toString(), AppTheme.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordTile(AttendanceRecord record) {
    final statusColor = record.isPresent
        ? AppTheme.success
        : record.isLate
        ? AppTheme.warning
        : AppTheme.error;

    final statusIcon = record.isPresent
        ? Icons.check_circle
        : record.isLate
        ? Icons.schedule
        : Icons.cancel;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 28),
        title: Text(
          'Attendance Record',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: record.remarks != null && record.remarks!.isNotEmpty
            ? Text(
                record.remarks!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.neutral.withOpacity(0.7),
                ),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                record.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final currentDate = DateTime.parse('$selectedMonth-01');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              selectedDate: currentDate,
              onChanged: (date) {
                setState(() {
                  selectedMonth = DateFormat('yyyy-MM').format(date);
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
