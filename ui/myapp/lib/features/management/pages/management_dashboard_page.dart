import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_theme.dart';
import '../providers/management_provider.dart';
import 'departments_page.dart';
import 'batches_page.dart';
import 'students_page.dart';

class ManagementDashboardPage extends ConsumerWidget {
  const ManagementDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🏠 Building ManagementDashboardPage...');
    final statsAsync = ref.watch(managementStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Dashboard'),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Students',
                      value: stats.totalStudents.toString(),
                      icon: Icons.people,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Departments',
                      value: stats.totalDepartments.toString(),
                      icon: Icons.business,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Batches',
                      value: stats.totalBatches.toString(),
                      icon: Icons.calendar_today,
                      color: AppTheme.accentPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),

              const SizedBox(height: 32),

              // Management Options
              const Text(
                'Manage',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _ManagementTile(
                title: 'Departments',
                subtitle: 'Add, edit, or remove departments',
                icon: Icons.business,
                color: AppTheme.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DepartmentsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ManagementTile(
                title: 'Batches',
                subtitle: 'Manage student batches/years',
                icon: Icons.calendar_today,
                color: AppTheme.accentGreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BatchesPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ManagementTile(
                title: 'Students',
                subtitle: 'Add or manage student records',
                icon: Icons.people,
                color: AppTheme.accentPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading dashboard: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(managementStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.neutral.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
