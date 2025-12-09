import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../services/api_service.dart';
import '../models/room.dart';
import '../models/student.dart';
import '../models/exam.dart';
import '../models/seating.dart';

// ==================== API SERVICE PROVIDER ====================

final apiServiceProvider = Provider<ApiService>((ref) {
  final apiClient = ApiClient.getInstance();
  return ApiService(apiClient.dio);
});

// ==================== ROOMS PROVIDERS ====================

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getRooms();
});

final roomsRefreshProvider = StateProvider<int>((ref) => 0);

// ==================== STUDENTS PROVIDERS ====================

final studentsProvider = FutureProvider.family<List<Student>, StudentFilters>((
  ref,
  filters,
) async {
  final api = ref.read(apiServiceProvider);
  return api.getStudents(
    departmentCode: filters.departmentCode,
    batchYear: filters.batchYear,
  );
});

class StudentFilters {
  final String? departmentCode;
  final int? batchYear;

  StudentFilters({this.departmentCode, this.batchYear});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentFilters &&
          runtimeType == other.runtimeType &&
          departmentCode == other.departmentCode &&
          batchYear == other.batchYear;

  @override
  int get hashCode => Object.hash(departmentCode, batchYear);
}

final studentFiltersProvider = StateProvider<StudentFilters>((ref) {
  return StudentFilters();
});

// ==================== EXAMS PROVIDERS ====================

final examsProvider = FutureProvider<List<Exam>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getExams();
});

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedSessionProvider = StateProvider<String?>((ref) => null);

// ==================== SEATING PROVIDERS ====================

final availableRoomsProvider =
    FutureProvider.family<AvailableRoomResponse, SeatingQuery>((
      ref,
      query,
    ) async {
      final api = ref.read(apiServiceProvider);
      return api.getAvailableRooms(
        examDate: query.examDate,
        session: query.session,
      );
    });

final seatingByRoomProvider =
    FutureProvider.family<List<SeatingEntry>, SeatingQuery>((
      ref,
      params,
    ) async {
      final api = ref.read(apiServiceProvider);
      return api.getSeatingByRoom(
        examDate: params.examDate,
        session: params.session,
        roomCode: params.roomCode!,
      );
    });

class SeatingQuery {
  final String examDate;
  final String session;
  final String? roomCode;

  SeatingQuery({required this.examDate, required this.session, this.roomCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatingQuery &&
          runtimeType == other.runtimeType &&
          examDate == other.examDate &&
          session == other.session &&
          roomCode == other.roomCode;

  @override
  int get hashCode => Object.hash(examDate, session, roomCode);
}

// ==================== DASHBOARD SUMMARY PROVIDER ====================

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final api = ref.read(apiServiceProvider);

  // Fetch all data in parallel
  final results = await Future.wait([
    api.getStudents(),
    api.getRooms(),
    api.getExams(),
  ]);

  final students = results[0] as List<Student>;
  final rooms = results[1] as List<Room>;
  final exams = results[2] as List<Exam>;

  // Calculate upcoming exams (next 7 days)
  final now = DateTime.now();
  final upcomingExams = exams.where((exam) {
    final examDate = DateTime.parse(exam.examDate);
    final diff = examDate.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }).length;

  return DashboardSummary(
    totalStudents: students.length,
    totalRooms: rooms.length,
    upcomingExams: upcomingExams,
    totalExams: exams.length,
  );
});

class DashboardSummary {
  final int totalStudents;
  final int totalRooms;
  final int upcomingExams;
  final int totalExams;

  DashboardSummary({
    required this.totalStudents,
    required this.totalRooms,
    required this.upcomingExams,
    required this.totalExams,
  });
}
