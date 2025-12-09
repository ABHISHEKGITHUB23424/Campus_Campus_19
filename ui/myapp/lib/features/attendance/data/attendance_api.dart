import 'package:dio/dio.dart';
import 'models/attendance.dart';
import 'models/attendance_record.dart';

/// API service for attendance-related operations
class AttendanceApi {
  final Dio _dio;

  AttendanceApi(this._dio);

  /// Submit attendance for a class session
  /// POST /api/attendance/attendance/take
  Future<Attendance> takeAttendance({
    required int classId,
    required String date, // YYYY-MM-DD
    required String session, // FN or AN
    required List<int> presentStudentIds,
  }) async {
    try {
      print('📝 Taking attendance for class $classId on $date ($session)');
      print('   Present students: ${presentStudentIds.length}');

      final response = await _dio.post(
        '/api/attendance/attendance/take',
        data: {
          'class_id': classId,
          'date': date,
          'session': session,
          'present_student_ids': presentStudentIds,
        },
      );

      final attendance = Attendance.fromJson(response.data);
      print(
        '✅ Attendance recorded: ${attendance.presentCount}/${attendance.totalStudents} present',
      );
      return attendance;
    } catch (e) {
      print('❌ Error taking attendance: $e');
      rethrow;
    }
  }

  /// Get attendance records for a class on a specific date
  /// GET /api/attendance/attendance/by-class-date?class_id=1&date=2024-01-15&session=FN
  Future<List<AttendanceRecord>> getAttendanceByClassAndDate({
    required int classId,
    required String date, // YYYY-MM-DD
    String? session, // FN or AN (optional)
  }) async {
    try {
      print(
        '🔍 Fetching attendance for class $classId on $date${session != null ? " ($session)" : ""}',
      );
      final queryParams = {'class_id': classId, 'date': date};
      if (session != null) {
        queryParams['session'] = session;
      }

      final response = await _dio.get(
        '/api/attendance/attendance/by-class-date',
        queryParameters: queryParams,
      );

      // Check if response is a list
      if (response.data is! List) {
        print('⚠️ Expected List but got: ${response.data.runtimeType}');
        print('   Data: ${response.data}');
        return [];
      }

      final List<dynamic> data = response.data as List<dynamic>;
      final records = data
          .map((json) => AttendanceRecord.fromJson(json))
          .toList();
      print('📦 Retrieved ${records.length} attendance records');
      return records;
    } catch (e) {
      print('❌ Error fetching attendance: $e');
      rethrow;
    }
  }

  /// Get student attendance for a specific month
  /// GET /api/attendance/attendance/student-monthly?student_id=123&month=2024-01
  Future<List<AttendanceRecord>> getStudentMonthlyAttendance({
    required int studentId,
    required String month, // Format: YYYY-MM
  }) async {
    try {
      print('🔍 Fetching attendance for student $studentId in month $month');
      final response = await _dio.get(
        '/api/attendance/attendance/student-monthly',
        queryParameters: {'student_id': studentId, 'month': month},
      );

      // Check if response is a list
      if (response.data is! List) {
        print('⚠️ Expected List but got: ${response.data.runtimeType}');
        print('   Data: ${response.data}');
        return [];
      }

      final List<dynamic> data = response.data as List<dynamic>;
      final records = data
          .map((json) => AttendanceRecord.fromJson(json))
          .toList();
      print('📦 Retrieved ${records.length} records for student');
      return records;
    } catch (e) {
      print('❌ Error fetching student attendance: $e');
      rethrow;
    }
  }

  /// Get daily attendance summary across all classes
  /// GET /api/attendance/attendance/daily-summary?date=2024-01-15
  Future<Map<String, dynamic>> getDailySummary({
    required String date, // YYYY-MM-DD
  }) async {
    try {
      print('🔍 Fetching daily attendance summary for $date');
      final response = await _dio.get(
        '/api/attendance/attendance/daily-summary',
        queryParameters: {'date': date},
      );
      print('✅ Daily summary retrieved');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error fetching daily summary: $e');
      rethrow;
    }
  }

  /// Get attendance summary for a specific class
  /// GET /api/attendance/attendance/class-summary/{class_id}?start_date=2024-01-01&end_date=2024-01-31
  Future<Map<String, dynamic>> getClassAttendanceSummary(
    int classId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      print('🔍 Fetching attendance summary for class $classId');
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/api/attendance/attendance/class-summary/$classId',
        queryParameters: queryParams,
      );
      print('✅ Class summary retrieved');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error fetching class summary: $e');
      rethrow;
    }
  }

  /// Delete an attendance record
  /// DELETE /api/attendance/attendance/{attendance_id}
  Future<void> deleteAttendance(int attendanceId) async {
    try {
      print('🗑️ Deleting attendance ID: $attendanceId');
      await _dio.delete('/api/attendance/attendance/$attendanceId');
      print('✅ Attendance deleted successfully');
    } catch (e) {
      print('❌ Error deleting attendance: $e');
      rethrow;
    }
  }

  // Legacy methods for backward compatibility
  @Deprecated('Use getStudentMonthlyAttendance instead')
  Future<List<AttendanceRecord>> getStudentAttendance(
    int studentId,
    String month,
  ) => getStudentMonthlyAttendance(studentId: studentId, month: month);

  /// Check if attendance already exists for a class/date/session
  Future<bool> checkAttendanceExists(
    int classId,
    String date,
    String session,
  ) async {
    try {
      final response = await _dio.get(
        '/api/attendance/attendance/check',
        queryParameters: {
          'class_id': classId,
          'date': date,
          'session': session,
        },
      );
      return response.data['exists'] as bool? ?? false;
    } catch (e) {
      // If endpoint doesn't exist, assume attendance doesn't exist
      return false;
    }
  }
}
