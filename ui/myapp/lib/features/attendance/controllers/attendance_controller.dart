import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../data/attendance_api.dart';
import '../data/models/attendance.dart';
import '../data/models/attendance_record.dart';
import '../data/models/student.dart';

/// Provider for AttendanceApi
final attendanceApiProvider = Provider<AttendanceApi>((ref) {
  final apiClient = ApiClient.getInstance();
  return AttendanceApi(apiClient.dio);
});

/// State for attendance taking
class AttendanceState {
  final List<Student> students;
  final Set<int> presentStudentIds;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;

  // Session info
  final int? classId;
  final DateTime? date;
  final String session; // FN or AN

  // Attendance record
  final Attendance? submittedAttendance;

  AttendanceState({
    this.students = const [],
    Set<int>? presentStudentIds,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
    this.classId,
    this.date,
    this.session = 'FN',
    this.submittedAttendance,
  }) : presentStudentIds = presentStudentIds ?? {};

  AttendanceState copyWith({
    List<Student>? students,
    Set<int>? presentStudentIds,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
    int? classId,
    DateTime? date,
    String? session,
    Attendance? submittedAttendance,
  }) {
    return AttendanceState(
      students: students ?? this.students,
      presentStudentIds: presentStudentIds ?? this.presentStudentIds,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      successMessage: successMessage,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      session: session ?? this.session,
      submittedAttendance: submittedAttendance ?? this.submittedAttendance,
    );
  }

  /// Get present count
  int get presentCount => presentStudentIds.length;

  /// Get absent count
  int get absentCount => students.length - presentCount;

  /// Get attendance percentage
  double get attendancePercentage {
    if (students.isEmpty) return 0.0;
    return (presentCount / students.length) * 100;
  }

  /// Check if all students are marked
  bool get allMarked => students.isNotEmpty;

  /// Check if ready to submit
  bool get canSubmit => classId != null && date != null && students.isNotEmpty;
}

/// Controller for managing attendance
class AttendanceController extends StateNotifier<AttendanceState> {
  final AttendanceApi _attendanceApi;

  AttendanceController(this._attendanceApi) : super(AttendanceState());

  /// Initialize attendance session
  void initializeSession({
    required int classId,
    required List<Student> students,
    DateTime? date,
    String session = 'FN',
  }) {
    state = AttendanceState(
      classId: classId,
      students: students,
      date: date ?? DateTime.now(),
      session: session,
    );
  }

  /// Set session date
  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Set session (FN or AN)
  void setSession(String session) {
    state = state.copyWith(session: session);
  }

  /// Toggle student attendance
  void toggleStudentAttendance(int studentId) {
    final newPresentIds = Set<int>.from(state.presentStudentIds);

    if (newPresentIds.contains(studentId)) {
      newPresentIds.remove(studentId);
    } else {
      newPresentIds.add(studentId);
    }

    state = state.copyWith(presentStudentIds: newPresentIds);
  }

  /// Mark student as present
  void markPresent(int studentId) {
    final newPresentIds = Set<int>.from(state.presentStudentIds)
      ..add(studentId);
    state = state.copyWith(presentStudentIds: newPresentIds);
  }

  /// Mark student as absent
  void markAbsent(int studentId) {
    final newPresentIds = Set<int>.from(state.presentStudentIds)
      ..remove(studentId);
    state = state.copyWith(presentStudentIds: newPresentIds);
  }

  /// Mark all students as present
  void markAllPresent() {
    final allIds = state.students.map((s) => s.id!).toSet();
    state = state.copyWith(presentStudentIds: allIds);
  }

  /// Mark all students as absent
  void markAllAbsent() {
    state = state.copyWith(presentStudentIds: {});
  }

  /// Check if student is marked present
  bool isPresent(int studentId) {
    return state.presentStudentIds.contains(studentId);
  }

  /// Submit attendance
  Future<bool> submitAttendance() async {
    if (!state.canSubmit) {
      state = state.copyWith(error: 'Missing required information');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final attendance = await _attendanceApi.takeAttendance(
        classId: state.classId!,
        date: _formatDate(state.date!),
        session: state.session,
        presentStudentIds: state.presentStudentIds.toList(),
      );

      state = state.copyWith(
        isSubmitting: false,
        submittedAttendance: attendance,
        successMessage: 'Attendance submitted successfully!',
      );

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  /// Check if attendance already exists
  Future<bool> checkDuplicateAttendance() async {
    if (state.classId == null || state.date == null) return false;

    try {
      return await _attendanceApi.checkAttendanceExists(
        state.classId!,
        _formatDate(state.date!),
        state.session,
      );
    } catch (e) {
      return false;
    }
  }

  /// Get attendance records by class and date
  Future<List<AttendanceRecord>?> getAttendanceByClassAndDate({
    required int classId,
    required String date,
  }) async {
    try {
      return await _attendanceApi.getAttendanceByClassAndDate(
        classId: classId,
        date: date,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get student monthly attendance
  Future<List<AttendanceRecord>?> getStudentMonthlyAttendance({
    required int studentId,
    required String month,
  }) async {
    try {
      return await _attendanceApi.getStudentMonthlyAttendance(
        studentId: studentId,
        month: month,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get daily attendance summary
  Future<Map<String, dynamic>?> getDailySummary({required String date}) async {
    try {
      return await _attendanceApi.getDailySummary(date: date);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get class attendance summary
  Future<Map<String, dynamic>?> getClassSummary({
    required int classId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _attendanceApi.getClassAttendanceSummary(
        classId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Delete an attendance record
  Future<bool> deleteAttendance(int attendanceId) async {
    try {
      await _attendanceApi.deleteAttendance(attendanceId);
      state = state.copyWith(
        successMessage: 'Attendance record deleted successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Format date for API (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }

  /// Reset state
  void reset() {
    state = AttendanceState();
  }
}

/// Provider for AttendanceController
final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
      final attendanceApi = ref.watch(attendanceApiProvider);
      return AttendanceController(attendanceApi);
    });

/// Provider for getting attendance records by class, date, and session
/// Uses a composite key "classId|date|session" to avoid Map identity issues
final attendanceRecordsProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, String>((ref, key) async {
      final parts = key.split('|');
      final classId = int.parse(parts[0]);
      final date = parts[1];
      final session = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;

      final attendanceApi = ref.watch(attendanceApiProvider);
      return attendanceApi.getAttendanceByClassAndDate(
        classId: classId,
        date: date,
        session: session,
      );
    });

/// Provider for getting student monthly attendance
/// Uses a composite key "studentId|month" to avoid Map identity issues
final studentAttendanceProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, String>((ref, key) async {
      final parts = key.split('|');
      final studentId = int.parse(parts[0]);
      final month = parts[1];

      final attendanceApi = ref.watch(attendanceApiProvider);
      return attendanceApi.getStudentMonthlyAttendance(
        studentId: studentId,
        month: month,
      );
    });

/// Provider for getting daily attendance summary
final dailySummaryProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, date) async {
      final attendanceApi = ref.watch(attendanceApiProvider);
      return attendanceApi.getDailySummary(date: date);
    });

/// Provider for getting class attendance summary
/// Uses a composite key "classId|startDate|endDate" (dates can be empty)
final classSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, key) async {
      final parts = key.split('|');
      final classId = int.parse(parts[0]);
      final startDate = parts.length > 1 && parts[1].isNotEmpty
          ? parts[1]
          : null;
      final endDate = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;

      final attendanceApi = ref.watch(attendanceApiProvider);
      return attendanceApi.getClassAttendanceSummary(
        classId,
        startDate: startDate,
        endDate: endDate,
      );
    });
