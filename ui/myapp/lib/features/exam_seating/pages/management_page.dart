import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/room.dart';
import '../utils/file_helper.dart';

/// Comprehensive Exam Seating Management Dashboard
/// Provides UI for all backend features: CSV uploads, data management, seating results
class ExamSeatingManagementPage extends StatefulWidget {
  const ExamSeatingManagementPage({super.key});

  @override
  State<ExamSeatingManagementPage> createState() =>
      _ExamSeatingManagementPageState();
}

class _ExamSeatingManagementPageState extends State<ExamSeatingManagementPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Exam Seating Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Rooms', 'Students', 'Exams', 'Seating Results'];
    return Container(
      color: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF00ADB5)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF00ADB5)
                        : Colors.white54,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return const RoomsTab();
      case 1:
        return const StudentsTab();
      case 2:
        return const ExamsTab();
      case 3:
        return const SeatingResultsTab();
      default:
        return const Center(child: Text('Unknown tab'));
    }
  }
}

/// ==================== ROOMS TAB ====================
class RoomsTab extends ConsumerStatefulWidget {
  const RoomsTab({super.key});

  @override
  ConsumerState<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends ConsumerState<RoomsTab> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCsvUploadSection(),
          const SizedBox(height: 24),
          const Text(
            'All Rooms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: roomsAsync.when(
              data: (rooms) => rooms.isEmpty
                  ? _buildEmptyState('No rooms added yet')
                  : _buildRoomsList(rooms),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCsvUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file, color: Color(0xFF00ADB5)),
              const SizedBox(width: 8),
              const Text(
                'Upload Rooms CSV',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'CSV format: code, capacity, rows (optional), columns (optional)',
            style: TextStyle(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadCsv,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Choose CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ADB5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _downloadSampleCsv,
                icon: const Icon(Icons.download),
                label: const Text('Sample'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00ADB5),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final api = ref.read(apiServiceProvider);
      final rooms = await api.uploadRoomsCsv(result.files.first);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${rooms.length} room(s) uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the rooms list
        ref.invalidate(roomsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _downloadSampleCsv() {
    const csvContent = '''code,capacity,rows,columns
A101,30,5,6
A102,40,6,7
B201,35,5,7''';

    FileHelper.downloadTextFile(csvContent, 'rooms_sample.csv');
  }

  Widget _buildRoomsList(List<Room> rooms) {
    return ListView.separated(
      itemCount: rooms.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final room = rooms[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF00ADB5).withOpacity(0.15),
            child: const Icon(Icons.meeting_room, color: Color(0xFF00ADB5)),
          ),
          title: Text(
            room.code,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Capacity: ${room.capacity}${room.rows != null && room.columns != null ? ' | Layout: ${room.rows}×${room.columns}' : ''}',
            style: const TextStyle(color: Colors.white60),
          ),
          trailing: room.rows != null && room.columns != null
              ? const Icon(Icons.grid_on, color: Color(0xFF00ADB5))
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading rooms',
            style: TextStyle(fontSize: 16, color: Colors.white60),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: Colors.red.shade300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// ==================== STUDENTS TAB ====================
class StudentsTab extends ConsumerStatefulWidget {
  const StudentsTab({super.key});

  @override
  ConsumerState<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends ConsumerState<StudentsTab> {
  bool _isUploading = false;
  String? _selectedDept;
  int? _selectedBatch;

  // Sample departments - in production, fetch from backend
  final List<String> _departments = ['CSE', 'IT', 'ECE', 'EEE', 'MECH'];
  final List<int> _batches = [2021, 2022, 2023, 2024];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCsvUploadSection(),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 16),
          const Text(
            'Students List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildStudentsList()),
        ],
      ),
    );
  }

  Widget _buildCsvUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file, color: Color(0xFF00ADB5)),
              const SizedBox(width: 8),
              const Text(
                'Upload Students CSV',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'CSV format: register_no, name, department_code, department_name, batch_year',
            style: TextStyle(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadCsv,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Choose CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ADB5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _downloadSampleCsv,
                icon: const Icon(Icons.download),
                label: const Text('Sample'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00ADB5),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Department',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            value: _selectedDept,
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ..._departments.map(
                (dept) => DropdownMenuItem(value: dept, child: Text(dept)),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedDept = value);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Batch Year',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            value: _selectedBatch,
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ..._batches.map(
                (batch) =>
                    DropdownMenuItem(value: batch, child: Text('$batch')),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedBatch = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsList() {
    // Create a provider key with filters
    final studentsAsync = ref.watch(
      studentsProvider(
        StudentFilters(
          departmentCode: _selectedDept,
          batchYear: _selectedBatch,
        ),
      ),
    );

    return studentsAsync.when(
      data: (students) => students.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'No students found',
                    style: TextStyle(fontSize: 16, color: Colors.white60),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF00ADB5).withOpacity(0.15),
                    child: Text(
                      student.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF00ADB5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    '${student.registerNo} | ${student.departmentCode ?? 'No Dept'} | Batch: ${student.batchYear ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final api = ref.read(apiServiceProvider);
      final students = await api.uploadStudentsCsv(result.files.first);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${students.length} student(s) uploaded successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the students list
        ref.invalidate(studentsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _downloadSampleCsv() {
    const csvContent =
        '''register_no,name,department_code,department_name,batch_year
2023001,John Doe,CSE,Computer Science,2023
2023002,Jane Smith,IT,Information Technology,2023
2022101,Bob Johnson,ECE,Electronics,2022''';

    FileHelper.downloadTextFile(csvContent, 'students_sample.csv');
  }
}

/// ==================== EXAMS TAB ====================
class ExamsTab extends ConsumerStatefulWidget {
  const ExamsTab({super.key});

  @override
  ConsumerState<ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends ConsumerState<ExamsTab> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(examsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCsvUploadSection(),
          const SizedBox(height: 24),
          const Text(
            'Scheduled Exams',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: examsAsync.when(
              data: (exams) => exams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 64,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exams scheduled',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: exams.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final exam = exams[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(
                              0xFF00ADB5,
                            ).withOpacity(0.15),
                            child: const Icon(
                              Icons.description,
                              color: Color(0xFF00ADB5),
                            ),
                          ),
                          title: Text(
                            '${exam.subjectCode} - ${exam.subjectName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${exam.examDate} | ${exam.session}',
                                style: const TextStyle(color: Colors.white60),
                              ),
                              Text(
                                'Depts: ${exam.departmentsPreview}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCsvUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file, color: Color(0xFF00ADB5)),
              const SizedBox(width: 8),
              const Text(
                'Upload Exams CSV',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'CSV format: subject_code, subject_name, exam_date (YYYY-MM-DD), session (FN/AN), department_batches (CSE:2023,IT:2024)',
            style: TextStyle(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadCsv,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Choose CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ADB5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _downloadSampleCsv,
                icon: const Icon(Icons.download),
                label: const Text('Sample'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00ADB5),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final api = ref.read(apiServiceProvider);
      final exams = await api.uploadExamsCsv(result.files.first);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exams.length} exam(s) uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(examsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _downloadSampleCsv() {
    const csvContent =
        '''subject_code,subject_name,exam_date,session,department_batches
CS101,Data Structures,2025-12-15,FN,"CSE:2023,IT:2023"
MA101,Mathematics,2025-12-16,AN,"CSE:2023,ECE:2023,EEE:2023"''';

    FileHelper.downloadTextFile(csvContent, 'exams_sample.csv');
  }
}

/// ==================== SEATING RESULTS TAB ====================
class SeatingResultsTab extends ConsumerStatefulWidget {
  const SeatingResultsTab({super.key});

  @override
  ConsumerState<SeatingResultsTab> createState() => _SeatingResultsTabState();
}

class _SeatingResultsTabState extends ConsumerState<SeatingResultsTab> {
  DateTime? _selectedDate;
  String _selectedSession = 'FN';
  String? _selectedRoom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'View & Download Seating Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222831),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 16),
          _buildDownloadButtons(),
          const SizedBox(height: 24),
          if (_selectedDate != null && _selectedRoom != null)
            Expanded(child: _buildSeatingPreview()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF00ADB5).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF00ADB5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : 'Select date',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Session',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                value: _selectedSession,
                items: const [
                  DropdownMenuItem(value: 'FN', child: Text('Forenoon')),
                  DropdownMenuItem(value: 'AN', child: Text('Afternoon')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedSession = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRoomDropdown(),
      ],
    );
  }

  Widget _buildRoomDropdown() {
    final roomsAsync = ref.watch(roomsProvider);

    return roomsAsync.when(
      data: (rooms) => DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Room (optional - for preview)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        value: _selectedRoom,
        items: [
          const DropdownMenuItem(value: null, child: Text('All Rooms')),
          ...rooms.map(
            (room) =>
                DropdownMenuItem(value: room.code, child: Text(room.code)),
          ),
        ],
        onChanged: (value) {
          setState(() => _selectedRoom = value);
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading rooms'),
    );
  }

  Widget _buildDownloadButtons() {
    final canDownload = _selectedDate != null;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: canDownload ? _downloadAllCsv : null,
          icon: const Icon(Icons.download),
          label: const Text('Download All Rooms CSV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00ADB5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (_selectedRoom != null)
          OutlinedButton.icon(
            onPressed: canDownload ? _downloadRoomCsv : null,
            icon: const Icon(Icons.download),
            label: Text('Download $_selectedRoom CSV'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00ADB5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (_selectedRoom != null)
          OutlinedButton.icon(
            onPressed: canDownload ? _viewSvg : null,
            icon: const Icon(Icons.visibility),
            label: const Text('View SVG Layout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF393E46),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSeatingPreview() {
    // TODO: Implement seating preview by fetching from backend
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Seating preview will appear here',
          style: const TextStyle(color: Colors.white60),
        ),
      ),
    );
  }

  Future<void> _downloadAllCsv() async {
    if (_selectedDate == null) return;

    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await api.downloadSeatingCsvAll(
        examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        session: _selectedSession,
      );

      final filename =
          'seating_all_${DateFormat('yyyy-MM-dd').format(_selectedDate!)}_$_selectedSession.csv';
      await FileHelper.downloadFile(bytes, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _downloadRoomCsv() async {
    if (_selectedDate == null || _selectedRoom == null) return;

    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await api.downloadSeatingCsvByRoom(
        examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        session: _selectedSession,
        roomCode: _selectedRoom!,
      );

      final filename =
          'seating_${_selectedRoom}_${DateFormat('yyyy-MM-dd').format(_selectedDate!)}_$_selectedSession.csv';
      await FileHelper.downloadFile(bytes, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _viewSvg() async {
    if (_selectedDate == null || _selectedRoom == null) return;

    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await api.getSvgByRoom(
        examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        session: _selectedSession,
        roomCode: _selectedRoom!,
      );

      // Save SVG file and show message
      final filename =
          'seating_${_selectedRoom}_${DateFormat('yyyy-MM-dd').format(_selectedDate!)}_$_selectedSession.svg';
      await FileHelper.downloadFile(bytes, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SVG opened in new tab!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
