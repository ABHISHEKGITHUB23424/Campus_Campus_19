import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../controllers/class_controller.dart';
import '../controllers/student_controller.dart';
import 'attendance_take_page.dart';

/// Class selector page for choosing class before taking attendance
class ClassSelectorPage extends ConsumerStatefulWidget {
  const ClassSelectorPage({super.key});

  @override
  ConsumerState<ClassSelectorPage> createState() => _ClassSelectorPageState();
}

class _ClassSelectorPageState extends ConsumerState<ClassSelectorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();

    // Load classes
    Future.microtask(() {
      ref.read(classControllerProvider.notifier).loadClasses();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(classControllerProvider);
    final classController = ref.read(classControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Select Class'), centerTitle: true),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: classState.isLoading
              ? const Center(
                  child: LoadingIndicator(message: 'Loading classes...'),
                )
              : classState.error != null
              ? _buildErrorView(classState.error!)
              : _buildContent(context, classState, classController),
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              'Failed to load classes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutral.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedButton(
              onPressed: () {
                ref.read(classControllerProvider.notifier).loadClasses();
              },
              icon: Icons.refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ClassState state,
    ClassController controller,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Find Your Class',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select department, year, and section to continue',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutral.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Filter Card
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.cardShadow,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Department Dropdown
                _buildDropdown(
                  label: 'Department',
                  value: state.selectedDepartment,
                  items: state.departments,
                  onChanged: (value) {
                    if (value != null) controller.setDepartment(value);
                  },
                  icon: Icons.business,
                ),
                const SizedBox(height: 20),

                // Year Dropdown
                _buildYearDropdown(
                  label: 'Year',
                  value: state.selectedYear,
                  items: state.years,
                  onChanged: (value) {
                    if (value != null) controller.setYear(value);
                  },
                  icon: Icons.school,
                  enabled: state.selectedDepartment != null,
                ),
                const SizedBox(height: 20),

                // Section Dropdown
                _buildDropdown(
                  label: 'Section',
                  value: state.selectedSection,
                  items: state.sections,
                  onChanged: (value) {
                    if (value != null) controller.setSection(value);
                  },
                  icon: Icons.class_,
                  enabled: state.selectedYear != null,
                ),

                if (state.selectedClass != null) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Selected Class Info
                  _buildSelectedClassInfo(context, state),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Continue Button
          AnimatedButton(
            onPressed: state.canFindClass
                ? () => _handleContinue(context, state)
                : null,
            icon: Icons.arrow_forward,
            child: const Text('Continue to Take Attendance'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    required IconData icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.accentCyan),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? AppTheme.backgroundLight
                : AppTheme.backgroundLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(color: AppTheme.neutral.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(
                color: AppTheme.accentCyan,
                width: 2,
              ),
            ),
            hintText: 'Select $label',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearDropdown({
    required String label,
    required int? value,
    required List<int> items,
    required ValueChanged<int?>? onChanged,
    required IconData icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.accentCyan),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          items: items
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text('Year $item')),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? AppTheme.backgroundLight
                : AppTheme.backgroundLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(color: AppTheme.neutral.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(
                color: AppTheme.accentCyan,
                width: 2,
              ),
            ),
            hintText: 'Select $label',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedClassInfo(BuildContext context, ClassState state) {
    final classInfo = state.selectedClass!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success, size: 20),
            const SizedBox(width: 8),
            Text(
              'Class Found',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classInfo.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      classInfo.subjectCode ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      classInfo.subjectName ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.neutral.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleContinue(BuildContext context, ClassState state) async {
    final classId = state.selectedClass!.id!;

    // Load students for this class
    await ref
        .read(studentControllerProvider.notifier)
        .loadStudentsByClass(classId);

    // Navigate to attendance taking page
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AttendanceTakePage(
            classId: classId,
            classInfo: state.selectedClass!,
          ),
        ),
      );
    }
  }
}
