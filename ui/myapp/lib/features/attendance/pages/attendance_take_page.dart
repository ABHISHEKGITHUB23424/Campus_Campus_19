import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../utils/snackbar.dart';
import '../../../utils/formatting.dart';
import '../widgets/attendance_header.dart';
import '../widgets/session_selector.dart';
import '../widgets/student_checkbox_tile.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/student_controller.dart';
import '../data/models/class_model.dart';
import '../data/models/student.dart';

/// Page for taking attendance for a selected class
class AttendanceTakePage extends ConsumerStatefulWidget {
  final int classId;
  final ClassModel classInfo;

  const AttendanceTakePage({
    super.key,
    required this.classId,
    required this.classInfo,
  });

  @override
  ConsumerState<AttendanceTakePage> createState() => _AttendanceTakePageState();
}

class _AttendanceTakePageState extends ConsumerState<AttendanceTakePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Load students and initialize attendance
    Future.microtask(() async {
      final studentState = ref.read(studentControllerProvider);
      final students = studentState.students;

      if (students.isEmpty) {
        await ref
            .read(studentControllerProvider.notifier)
            .loadStudentsByClass(widget.classId);

        final updatedStudents = ref.read(studentControllerProvider).students;
        _initializeAttendance(updatedStudents);
      } else {
        _initializeAttendance(students);
      }
    });
  }

  void _initializeAttendance(List<Student> students) {
    ref
        .read(attendanceControllerProvider.notifier)
        .initializeSession(
          classId: widget.classId,
          students: students,
          date: selectedDate,
          session: 'FN',
        );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentControllerProvider);
    final attendanceState = ref.watch(attendanceControllerProvider);
    final attendanceController = ref.read(
      attendanceControllerProvider.notifier,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Take Attendance'),
        actions: [
          // Mark All Present/Absent
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'mark_all_present') {
                attendanceController.markAllPresent();
              } else if (value == 'mark_all_absent') {
                attendanceController.markAllAbsent();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_present',
                child: Row(
                  children: [
                    Icon(Icons.check_box, color: AppTheme.success),
                    SizedBox(width: 12),
                    Text('Mark All Present'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mark_all_absent',
                child: Row(
                  children: [
                    Icon(Icons.check_box_outline_blank, color: AppTheme.error),
                    SizedBox(width: 12),
                    Text('Mark All Absent'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: studentState.isLoading
          ? const Center(
              child: LoadingIndicator(message: 'Loading students...'),
            )
          : studentState.error != null
          ? _buildErrorView(studentState.error!)
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header with class info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AttendanceHeader(
                      classInfo: widget.classInfo,
                      date: selectedDate,
                      session: attendanceState.session,
                    ),
                  ),

                  // Date and Session Selectors
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Date Picker
                        Expanded(child: _buildDateSelector(context)),
                        const SizedBox(width: 16),
                        // Session Selector
                        SessionSelector(
                          selectedSession: attendanceState.session,
                          onSessionChanged: (session) {
                            attendanceController.setSession(session);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Attendance Stats
                  _buildStatsBar(attendanceState),

                  const SizedBox(height: 8),

                  // Student List
                  Expanded(child: _buildStudentList(attendanceState)),

                  // Submit Button
                  _buildSubmitButton(
                    context,
                    attendanceState,
                    attendanceController,
                  ),
                ],
              ),
            ),
      floatingActionButton: attendanceState.isSubmitting
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(color: AppTheme.white),
            )
          : null,
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
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
              'Failed to load students',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            AnimatedButton(
              onPressed: () {
                ref
                    .read(studentControllerProvider.notifier)
                    .loadStudentsByClass(widget.classId);
              },
              icon: Icons.refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppTheme.accentCyan,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formatDateDisplay(selectedDate),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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
              surface: AppTheme.white,
              onSurface: AppTheme.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      ref.read(attendanceControllerProvider.notifier).setDate(picked);
    }
  }

  Widget _buildStatsBar(AttendanceState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _buildStatItem(
            label: 'Total',
            value: state.students.length.toString(),
            color: AppTheme.neutral,
            icon: Icons.people,
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.neutral.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            label: 'Present',
            value: state.presentCount.toString(),
            color: AppTheme.success,
            icon: Icons.check_circle,
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.neutral.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            label: 'Absent',
            value: state.absentCount.toString(),
            color: AppTheme.error,
            icon: Icons.cancel,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPercentageColor(
                state.attendancePercentage,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              '${state.attendancePercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getPercentageColor(state.attendancePercentage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.neutral.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return AppTheme.success;
    if (percentage >= 50) return AppTheme.warning;
    return AppTheme.error;
  }

  Widget _buildStudentList(AttendanceState state) {
    if (state.students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.neutral.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.neutral.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.students.length,
      itemBuilder: (context, index) {
        final student = state.students[index];
        final controller = ref.read(attendanceControllerProvider.notifier);

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: StudentCheckboxTile(
            student: student,
            isPresent: controller.isPresent(student.id!),
            onChanged: (isPresent) {
              controller.toggleStudentAttendance(student.id!);
            },
            index: index,
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    AttendanceState state,
    AttendanceController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedButton(
          onPressed: state.isSubmitting
              ? null
              : () => _handleSubmit(context, state, controller),
          isLoading: state.isSubmitting,
          icon: Icons.check,
          child: const Text('Submit Attendance'),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    AttendanceState state,
    AttendanceController controller,
  ) async {
    // Check for duplicate attendance
    final isDuplicate = await controller.checkDuplicateAttendance();

    if (isDuplicate && context.mounted) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Duplicate Attendance'),
          content: Text(
            'Attendance for ${formatSession(state.session)} session on ${formatDateDisplay(state.date!)} already exists. Do you want to overwrite it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: const Text('Overwrite'),
            ),
          ],
        ),
      );

      if (shouldContinue != true) return;
    }

    // Submit attendance
    final success = await controller.submitAttendance();

    if (!context.mounted) return;

    if (success) {
      showSuccessSnackbar(context, 'Attendance submitted successfully!');

      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    } else {
      showErrorSnackbar(context, state.error ?? 'Failed to submit attendance');
    }
  }
}
