import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/management_provider.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({Key? key}) : super(key: key);

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final registerNoController = TextEditingController();
    final nameController = TextEditingController();
    final sectionController = TextEditingController();

    String? selectedDepartment;
    int? selectedBatchYear;

    // Fetch departments and batches
    final departmentsAsync = ref.read(departmentsProvider);
    final batchesAsync = ref.read(batchesProvider);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: registerNoController,
                decoration: const InputDecoration(
                  labelText: 'Register Number',
                  hintText: 'e.g., REG123456',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  hintText: 'e.g., John Doe',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              departmentsAsync.when(
                data: (departments) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Department'),
                  value: selectedDepartment,
                  items: departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept.code,
                      child: Text('${dept.code} - ${dept.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedDepartment = value;
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading departments'),
              ),
              const SizedBox(height: 16),
              batchesAsync.when(
                data: (batches) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Batch Year'),
                  value: selectedBatchYear,
                  items: batches.map((batch) {
                    return DropdownMenuItem(
                      value: batch.year,
                      child: Text('${batch.year} - ${batch.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedBatchYear = value;
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading batches'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section (Optional)',
                  hintText: 'e.g., A',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (registerNoController.text.trim().isEmpty ||
                  nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill register number and name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final api = ref.read(managementApiProvider);
                await api.createStudent({
                  'register_no': registerNoController.text.trim().toUpperCase(),
                  'name': nameController.text.trim(),
                  'department_code': selectedDepartment,
                  'batch_year': selectedBatchYear,
                  'section': sectionController.text.trim().isEmpty
                      ? null
                      : sectionController.text.trim().toUpperCase(),
                });

                ref.invalidate(managementStatsProvider);
                Navigator.pop(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                registerNoController.dispose();
                nameController.dispose();
                sectionController.dispose();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(managementStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: statsAsync.when(
        data: (stats) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${stats.totalStudents}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Total Students'),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 48,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${stats.totalDepartments}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Departments'),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 48,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${stats.totalBatches}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Batches'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Students by Department',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: stats.studentsByDepartment.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No students found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first student',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: stats.studentsByDepartment.length,
                          itemBuilder: (context, index) {
                            final entry = stats.studentsByDepartment.entries
                                .elementAt(index);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: Text(
                                    entry.key.substring(0, 1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${entry.value} students',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading students',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(managementStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
    );
  }
}
