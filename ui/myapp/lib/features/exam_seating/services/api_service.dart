import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../config.dart';
import '../models/room.dart';
import '../models/student.dart';
import '../models/exam.dart';
import '../models/seating.dart';

/// API Service for Exam Seating Backend
/// Uses Dio for HTTP requests with consistent error handling
class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    // Add specific interceptors for exam seating if needed
    // The main auth interceptors are handled by ApiClient
  }

  String _extractErrorMessage(DioException error) {
    if (error.response?.data is Map) {
      final data = error.response!.data as Map;
      if (data.containsKey('detail')) {
        return data['detail'].toString();
      }
    }
    return error.message ?? 'Unknown error occurred';
  }

  // ==================== HEALTH CHECK ====================

  /// Check backend health status
  /// GET /health
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _dio.get(AppConfig.healthEndpoint);
    return response.data as Map<String, dynamic>;
  }

  // ==================== ROOMS ====================

  /// Get all rooms
  /// GET /api/seating/v1/rooms/
  Future<List<Room>> getRooms() async {
    try {
      print(
        '🔍 Fetching rooms from: ${AppConfig.apiBaseUrl}${AppConfig.roomsEndpoint}/',
      );
      final response = await _dio.get('${AppConfig.roomsEndpoint}/');
      print('📦 Rooms response: ${response.data}');

      // Check if response is a list before casting
      if (response.data is! List) {
        throw Exception('Expected list but got: ${response.data}');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      print('💥 Error fetching rooms: $e');
      rethrow;
    }
  }

  /// Create multiple rooms
  /// POST /api/v1/rooms/bulk
  /// Body: [{"code":"A101","capacity":30,"rows":5,"columns":6}, ...]
  Future<Map<String, dynamic>> createRoomsBulk(List<Room> rooms) async {
    final response = await _dio.post(
      '${AppConfig.roomsEndpoint}/bulk',
      data: rooms.map((r) => r.toJson()).toList(),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Upload rooms CSV
  /// POST /api/v1/rooms/upload-csv
  /// Multipart form-data with file
  Future<List<Room>> uploadRoomsCsv(PlatformFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
    });

    final response = await _dio.post(
      '${AppConfig.roomsEndpoint}/upload-csv',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (response.data is! List) {
      throw Exception('Expected list but got: ${response.data}');
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Room.fromJson(json)).toList();
  }

  // ==================== STUDENTS ====================

  /// Get all students with optional filters
  /// GET /api/v1/students/?department_code=CSE&batch_year=2023
  Future<List<Student>> getStudents({
    String? departmentCode,
    int? batchYear,
  }) async {
    final queryParams = <String, dynamic>{};
    if (departmentCode != null) queryParams['department_code'] = departmentCode;
    if (batchYear != null) queryParams['batch_year'] = batchYear;

    final response = await _dio.get(
      '${AppConfig.studentsEndpoint}/',
      queryParameters: queryParams,
    );

    if (response.data is! List) {
      throw Exception('Expected list but got: ${response.data}');
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Student.fromJson(json)).toList();
  }

  /// Create multiple students
  /// POST /api/v1/students/bulk
  Future<Map<String, dynamic>> createStudentsBulk(
    List<Student> students,
  ) async {
    final response = await _dio.post(
      '${AppConfig.studentsEndpoint}/bulk',
      data: students.map((s) => s.toJson()).toList(),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Upload students CSV
  /// POST /api/v1/students/upload-csv
  Future<List<Student>> uploadStudentsCsv(PlatformFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
    });

    final response = await _dio.post(
      '${AppConfig.studentsEndpoint}/upload-csv',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (response.data is! List) {
      throw Exception('Expected list but got: ${response.data}');
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Student.fromJson(json)).toList();
  }

  // ==================== EXAMS ====================

  /// Get all exams
  /// GET /api/v1/exams/
  Future<List<Exam>> getExams() async {
    final response = await _dio.get('${AppConfig.examsEndpoint}/');

    if (response.data is! List) {
      throw Exception('Expected list but got: ${response.data}');
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Exam.fromJson(json)).toList();
  }

  /// Create a new exam
  /// POST /api/v1/exams/
  Future<Exam> createExam(Exam exam) async {
    final response = await _dio.post(
      AppConfig.examsEndpoint,
      data: exam.toJson(),
    );
    return Exam.fromJson(response.data);
  }

  /// Upload exams CSV
  /// POST /api/v1/exams/upload-csv
  Future<List<Exam>> uploadExamsCsv(PlatformFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
    });

    final response = await _dio.post(
      '${AppConfig.examsEndpoint}/upload-csv',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (response.data is! List) {
      throw Exception('Expected list but got: ${response.data}');
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Exam.fromJson(json)).toList();
  }

  // ==================== SEATING ====================

  /// Check available rooms for an exam
  /// GET /api/v1/seating/available-rooms?exam_date=2025-12-15&session=FN
  Future<AvailableRoomResponse> getAvailableRooms({
    required String examDate,
    required String session,
  }) async {
    final response = await _dio.get(
      '${AppConfig.seatingEndpoint}/available-rooms',
      queryParameters: {'exam_date': examDate, 'session': session},
    );
    return AvailableRoomResponse.fromJson(response.data);
  }

  /// Generate seating arrangement
  /// POST /api/v1/seating/generate
  Future<GenerateSeatingResponse> generateSeating(
    GenerateSeatingRequest request,
  ) async {
    final response = await _dio.post(
      '${AppConfig.seatingEndpoint}/generate',
      data: request.toJson(),
    );
    return GenerateSeatingResponse.fromJson(response.data);
  }

  /// Get seating by room
  /// GET /api/v1/seating/by-room?exam_date=2025-12-15&session=FN&room_code=A101
  Future<List<SeatingEntry>> getSeatingByRoom({
    required String examDate,
    required String session,
    required String roomCode,
  }) async {
    final response = await _dio.get(
      '${AppConfig.seatingEndpoint}/by-room',
      queryParameters: {
        'exam_date': examDate,
        'session': session,
        'room_code': roomCode,
      },
    );

    if (response.data is! List) {
      throw Exception('Expected list but got: ${response.data}');
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => SeatingEntry.fromJson(json)).toList();
  }

  /// Download seating CSV for a specific room
  /// GET /api/v1/seating/download-csv/by-room?exam_date=...&session=...&room_code=...
  /// Returns bytes to save as CSV file
  Future<List<int>> downloadSeatingCsvByRoom({
    required String examDate,
    required String session,
    required String roomCode,
  }) async {
    final response = await _dio.get(
      '${AppConfig.seatingEndpoint}/download-csv/by-room',
      queryParameters: {
        'exam_date': examDate,
        'session': session,
        'room_code': roomCode,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as List<int>;
  }

  /// Download seating CSV for all rooms
  /// GET /api/v1/seating/download-csv/all?exam_date=...&session=...
  Future<List<int>> downloadSeatingCsvAll({
    required String examDate,
    required String session,
  }) async {
    final response = await _dio.get(
      '${AppConfig.seatingEndpoint}/download-csv/all',
      queryParameters: {'exam_date': examDate, 'session': session},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as List<int>;
  }

  /// Get SVG visualization for a room
  /// GET /api/v1/seating/svg/by-room?exam_date=...&session=...&room_code=...
  /// Returns SVG bytes
  Future<List<int>> getSvgByRoom({
    required String examDate,
    required String session,
    required String roomCode,
  }) async {
    final response = await _dio.get(
      '${AppConfig.seatingEndpoint}/svg/by-room',
      queryParameters: {
        'exam_date': examDate,
        'session': session,
        'room_code': roomCode,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as List<int>;
  }
}
