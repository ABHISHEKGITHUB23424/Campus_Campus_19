import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../utils/formatting.dart';
import '../controllers/class_controller.dart';
import '../data/attendance_api.dart';
import '../data/models/attendance_record.dart';
import '../controllers/attendance_controller.dart';

/// Attendance summary page showing class attendance for a specific date
class AttendanceSummaryPage extends ConsumerStatefulWidget {
  const AttendanceSummaryPage({super.key});

  @override
  ConsumerState<AttendanceSummaryPage> createState() =>
      _AttendanceSummaryPageState();
}

class _AttendanceSummaryPageState extends ConsumerState<AttendanceSummaryPage> {
  int? selectedClassId;
  DateTime selectedDate = DateTime.now();
  String selectedSession = 'FN';
  String statusFilter = 'all'; // 'all', 'present', 'absent'

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(classControllerProvider.notifier).loadClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(classControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Attendance Summary'), elevation: 0),
      body: classState.isLoading
          ? const Center(child: LoadingIndicator(message: 'Loading classes...'))
          : Column(
              children: [
                // Filters Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.white, AppTheme.backgroundLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentCyan.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.filter_list,
                              color: AppTheme.accentCyan,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Filter Attendance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Class Dropdown
                      DropdownButtonFormField<int>(
                        value: selectedClassId,
                        decoration: InputDecoration(
                          labelText: 'Select Class',
                          prefixIcon: const Icon(Icons.class_),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.white,
                        ),
                        items: classState.classes.map((classModel) {
                          return DropdownMenuItem(
                            value: classModel.id,
                            child: Text(classModel.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedClassId = value);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Select Date',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppTheme.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDateDisplay(selectedDate),
                                style: const TextStyle(fontSize: 15),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: AppTheme.neutral,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Session Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.neutral.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSessionChip('FN', 'Forenoon'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSessionChip('AN', 'Afternoon'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Attendance Records
                Expanded(
                  child: selectedClassId == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCyan.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: AppTheme.accentCyan.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Select a class to view attendance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.neutral.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose from the dropdown above',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.neutral.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildAttendanceRecords(),
                ),
              ],
            ),
    );
  }

  Widget _buildSessionChip(String session, String label) {
    final isSelected = selectedSession == session;
    return InkWell(
      onTap: () => setState(() => selectedSession = session),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentCyan : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentCyan
                : AppTheme.neutral.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentCyan.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              session == 'FN' ? Icons.wb_sunny : Icons.nights_stay,
              size: 18,
              color: isSelected ? AppTheme.white : AppTheme.neutral,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.white : AppTheme.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecords() {
    final formattedDate = formatDateApi(selectedDate);
    final key = '${selectedClassId!}|$formattedDate|$selectedSession';

    print('🔍 Building attendance records with key: $key');
    print('   selectedDate: $selectedDate');
    print('   formattedDate: $formattedDate');
    print('   selectedSession: $selectedSession');

    final attendanceRecordsAsync = ref.watch(attendanceRecordsProvider(key));

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
                  'for ${formatDateDisplay(selectedDate)}',
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
        final present = records.where((r) => r.isPresent).length;
        final absent = records.where((r) => r.isAbsent).length;
        final total = records.length;
        final percentage = total > 0 ? (present / total) * 100 : 0.0;

        // Filter records based on selection
        final filteredRecords = statusFilter == 'all'
            ? records
            : statusFilter == 'present'
            ? records.where((r) => r.isPresent).toList()
            : records.where((r) => r.isAbsent).toList();

        return Column(
          children: [
            // Percentage Summary Card
            _buildPercentageCard(present, absent, total, percentage),

            // Filter Buttons
            _buildFilterButtons(present, absent, total),

            const SizedBox(height: 8),

            // Records List
            Expanded(
              child: filteredRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            statusFilter == 'present'
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 64,
                            color: AppTheme.neutral.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${statusFilter} students',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.neutral.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return _buildRecordTile(record);
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: LoadingIndicator(message: 'Loading attendance records...'),
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
                'Error loading records',
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

  Widget _buildPercentageCard(
    int present,
    int absent,
    int total,
    double percentage,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPercentageColor(percentage),
            _getPercentageColor(percentage).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: _getPercentageColor(percentage).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppTheme.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Attendance Rate',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
              Text(
                '$present of $total students',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up,
              color: AppTheme.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(int present, int absent, int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              'All',
              total.toString(),
              'all',
              Icons.people_outline,
              AppTheme.accentCyan,
            ),
          ),
          Expanded(
            child: _buildFilterButton(
              'Present',
              present.toString(),
              'present',
              Icons.check_circle_outline,
              AppTheme.success,
            ),
          ),
          Expanded(
            child: _buildFilterButton(
              'Absent',
              absent.toString(),
              'absent',
              Icons.cancel_outlined,
              AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    String count,
    String filterValue,
    IconData icon,
    Color color,
  ) {
    final isSelected = statusFilter == filterValue;
    return InkWell(
      onTap: () => setState(() => statusFilter = filterValue),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.white : color, size: 24),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.white : color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppTheme.white
                    : AppTheme.neutral.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTile(AttendanceRecord record) {
    final statusColor = record.isPresent
        ? AppTheme.success
        : record.isLate
        ? AppTheme.warning
        : AppTheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.15),
                statusColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Icon(
              record.isPresent
                  ? Icons.check_rounded
                  : record.isLate
                  ? Icons.schedule_rounded
                  : Icons.close_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
        ),
        title: Text(
          record.studentName ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 14,
                color: AppTheme.neutral.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                record.registerNo ?? '-',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.neutral.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [statusColor, statusColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            record.status.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return AppTheme.success;
    if (percentage >= 50) return AppTheme.warning;
    return AppTheme.error;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.accentCyan,
              onPrimary: AppTheme.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
}
