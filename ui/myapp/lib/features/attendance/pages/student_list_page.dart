import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../theme/app_theme.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../utils/snackbar.dart';
import '../controllers/student_controller.dart';
import '../controllers/class_controller.dart';
import '../data/models/student.dart';

/// Student list page with add/upload functionality
class StudentListPage extends ConsumerStatefulWidget {
  const StudentListPage({super.key});

  @override
  ConsumerState<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends ConsumerState<StudentListPage> {
  int? selectedClassId;

  @override
  void initState() {
    super.initState();
    // Load classes
    Future.microtask(() {
      ref.read(classControllerProvider.notifier).loadClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(classControllerProvider);
    final studentState = ref.watch(studentControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Student List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStudentDialog(context),
            tooltip: 'Add Student',
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _showUploadDialog(context),
            tooltip: 'Upload CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          // Class Selector
          _buildClassSelector(classState),

          // Student List
          Expanded(
            child: studentState.isLoading
                ? const Center(
                    child: LoadingIndicator(message: 'Loading students...'),
                  )
                : studentState.error != null
                ? _buildErrorView(studentState.error!)
                : _buildStudentList(studentState.students),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector(ClassState classState) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: AppTheme.accentCyan),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedClassId,
                hint: const Text('Select a class'),
                isExpanded: true,
                items: classState.classes.map((classModel) {
                  return DropdownMenuItem<int>(
                    value: classModel.id,
                    child: Text(classModel.displayName),
                  );
                }).toList(),
                onChanged: (classId) {
                  if (classId != null) {
                    setState(() => selectedClassId = classId);
                    ref
                        .read(studentControllerProvider.notifier)
                        .loadStudentsByClass(classId);
                  }
                },
              ),
            ),
          ),
        ],
      ),
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
              'Error',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.error),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList(List<Student> students) {
    if (students.isEmpty) {
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
              selectedClassId == null
                  ? 'Select a class to view students'
                  : 'No students found',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.neutral.withOpacity(0.7),
              ),
            ),
            if (selectedClassId != null) ...[
              const SizedBox(height: 24),
              AnimatedButton(
                onPressed: () => _showAddStudentDialog(context),
                icon: Icons.person_add,
                child: const Text('Add First Student'),
              ),
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppTheme.primaryDark.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(
              label: Text(
                'Roll No',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Register No',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Department',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Year',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Section',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: students.map((student) {
            return DataRow(
              cells: [
                DataCell(Text(student.rollNo ?? '-')),
                DataCell(Text(student.registerNo ?? '-')),
                DataCell(Text(student.name)),
                DataCell(Text(student.department)),
                DataCell(Text(student.year.toString())),
                DataCell(Text(student.section)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    if (selectedClassId == null) {
      showWarningSnackbar(context, 'Please select a class first');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddStudentSheet(classId: selectedClassId!),
    );
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    if (selectedClassId == null) {
      showWarningSnackbar(context, 'Please select a class first');
      return;
    }

    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      final file = result.files.first;

      if (file.bytes == null) {
        showErrorSnackbar(context, 'Failed to read file');
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create form data
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
        'class_id': selectedClassId,
      });

      // Upload and store response
      print('⏳ Starting upload...');
      final response = await ref
          .read(studentApiProvider)
          .uploadStudents(formData);

      print('📤 Upload response received: $response');

      // Parse response immediately
      final successCount = response['success_count'] ?? 0;
      final failedCount = response['failed_count'] ?? 0;
      final errors = response['errors'] as List<dynamic>? ?? [];

      print(
        '✅ Parsed - Success: $successCount, Failed: $failedCount, Errors: ${errors.length}',
      );

      // Close loading dialog FIRST
      print('🚪 Closing loading dialog...');
      if (!mounted) {
        print('⚠️ Widget not mounted, cannot close dialog');
        return;
      }
      Navigator.pop(context);
      print('✅ Loading dialog closed');

      // Refresh student list
      print('🔄 Invalidating student list...');
      ref.invalidate(studentsByClassProvider(selectedClassId!));

      // Show detailed results
      print('📊 Showing results...');
      if (!mounted) {
        print('⚠️ Widget not mounted, cannot show results');
        return;
      }

      if (successCount > 0 && failedCount == 0) {
        // All succeeded
        print('🎉 All succeeded case');
        showSuccessSnackbar(
          context,
          'Successfully uploaded $successCount students!',
        );
      } else if (successCount > 0 && failedCount > 0) {
        // Partial success
        print('⚠️ Partial success case');
        showWarningSnackbar(
          context,
          'Uploaded $successCount students, $failedCount duplicates skipped',
        );

        // Show error details in a dialog
        _showUploadResultsDialog(context, successCount, failedCount, errors);
      } else if (successCount == 0 && failedCount > 0) {
        // All failed
        print('❌ All duplicates case');
        showWarningSnackbar(context, 'All $failedCount students already exist');

        // Show error details
        _showUploadResultsDialog(context, successCount, failedCount, errors);
      } else {
        // Unknown response
        print('❓ Unknown response case');
        showSuccessSnackbar(context, 'Upload completed');
      }
      print('✅ Results displayed successfully');
    } on Exception catch (e, stackTrace) {
      print('❌ Upload exception: $e');
      print('Stack trace: $stackTrace');

      // Close loading dialog if open
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        showErrorSnackbar(context, 'Upload failed: ${e.toString()}');
      }
    } catch (e, stackTrace) {
      print('❌ Upload error: $e');
      print('Stack trace: $stackTrace');
      // Close loading dialog if open
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        showErrorSnackbar(context, 'Upload failed: ${e.toString()}');
      }
    }
  }

  void _showUploadResultsDialog(
    BuildContext context,
    int successCount,
    int failedCount,
    List<dynamic> errors,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              failedCount > 0
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle,
              color: failedCount > 0 ? Colors.orange : AppTheme.accentCyan,
            ),
            const SizedBox(width: 12),
            const Text('Upload Results'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Uploaded:'),
                        Text(
                          '$successCount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duplicates/Errors:'),
                        Text(
                          '$failedCount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Error list
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Issues:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.neutral),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: errors.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppTheme.neutral),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errors[index].toString(),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for adding a new student
class _AddStudentSheet extends ConsumerStatefulWidget {
  final int classId;

  const _AddStudentSheet({required this.classId});

  @override
  ConsumerState<_AddStudentSheet> createState() => _AddStudentSheetState();
}

class _AddStudentSheetState extends ConsumerState<_AddStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _registerNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _registerNoController.dispose();
    _nameController.dispose();
    _rollNoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.person_add, color: AppTheme.accentCyan),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Student',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Fields
              TextFormField(
                controller: _registerNoController,
                decoration: const InputDecoration(
                  labelText: 'Register Number',
                  hintText: 'e.g., 2021CS001',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter register number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g., John Doe',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _rollNoController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                  hintText: 'e.g., 1, 2, 3...',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter roll number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'e.g., student@example.com',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (Optional)',
                  hintText: 'e.g., 1234567890',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Submit Button
              AnimatedButton(
                onPressed: _handleSubmit,
                icon: Icons.check,
                child: const Text('Add Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Get class info to populate required fields
    final classController = ref.read(classControllerProvider);
    final selectedClass = classController.classes.firstWhere(
      (c) => c.id == widget.classId,
    );

    final student = Student(
      registerNo: _registerNoController.text.trim(),
      name: _nameController.text.trim(),
      department: selectedClass.department,
      year: selectedClass.year,
      section: selectedClass.section,
      rollNo: _rollNoController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      classId: widget.classId,
    );

    try {
      await ref.read(studentControllerProvider.notifier).addStudent(student);

      if (mounted) {
        showSuccessSnackbar(context, 'Student added successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Failed to add student: ${e.toString()}');
      }
    }
  }
}
