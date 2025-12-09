import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../utils/snackbar.dart';
import '../controllers/class_controller.dart';
import '../data/models/class_model.dart';

/// Page for adding a new class
class AddClassPage extends ConsumerStatefulWidget {
  const AddClassPage({super.key});

  @override
  ConsumerState<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends ConsumerState<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final _subjectNameController = TextEditingController();
  int _selectedYear = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _departmentController.dispose();
    _sectionController.dispose();
    _subjectCodeController.dispose();
    _subjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Add New Class'),
        backgroundColor: AppTheme.accentCyan,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Department
              _buildTextField(
                controller: _departmentController,
                label: 'Department',
                hint: 'e.g., CSBS, CSE, ECE, EEE',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Year Selector
              _buildYearSelector(),
              const SizedBox(height: 16),

              // Section
              _buildTextField(
                controller: _sectionController,
                label: 'Section',
                hint: 'e.g., A, B, C',
                icon: Icons.group,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter section';
                  }
                  if (value.length > 1) {
                    return 'Section should be a single character';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subject Code (Optional)
              _buildTextField(
                controller: _subjectCodeController,
                label: 'Subject Code (Optional)',
                hint: 'e.g., CS101, EC203',
                icon: Icons.book,
              ),
              const SizedBox(height: 16),

              // Subject Name (Optional)
              _buildTextField(
                controller: _subjectNameController,
                label: 'Subject Name (Optional)',
                hint: 'e.g., Data Structures, Mathematics',
                icon: Icons.subject,
              ),
              const SizedBox(height: 32),

              // Submit Button
              AnimatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                icon: _isLoading ? null : Icons.check,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Create Class'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.accentCyan),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      textCapitalization: TextCapitalization.characters,
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Select Year',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (index) {
              final year = index + 1;
              final isSelected = _selectedYear == year;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedYear = year;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentCyan
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentCyan
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Year $year',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final classModel = ClassModel(
      department: _departmentController.text.trim().toUpperCase(),
      year: _selectedYear,
      section: _sectionController.text.trim().toUpperCase(),
      subjectCode: _subjectCodeController.text.trim().isEmpty
          ? null
          : _subjectCodeController.text.trim().toUpperCase(),
      subjectName: _subjectNameController.text.trim().isEmpty
          ? null
          : _subjectNameController.text.trim(),
    );

    try {
      final result = await ref
          .read(classControllerProvider.notifier)
          .createClass(classModel);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result != null) {
          showSuccessSnackbar(
            context,
            'Class created successfully: ${result.displayName}',
          );
          Navigator.pop(context, result);
        } else {
          showErrorSnackbar(context, 'Failed to create class');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorSnackbar(context, 'Error: $e');
      }
    }
  }
}
