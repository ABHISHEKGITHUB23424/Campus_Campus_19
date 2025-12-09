import 'package:dio/dio.dart';
import 'models/student.dart';

/// API service for student-related operations
class StudentApi {
  final Dio _dio;

  StudentApi(this._dio);

  /// Create a new student
  /// POST /api/attendance/students/
  Future<Student> createStudent(Student student) async {
    try {
      print('➕ Creating student: ${student.name}');
      final response = await _dio.post(
        '/api/attendance/students/',
        data: student.toJson(),
      );
      final newStudent = Student.fromJson(response.data);
      print('✅ Student created with ID: ${newStudent.id}');
      return newStudent;
    } catch (e) {
      print('❌ Error creating student: $e');
      rethrow;
    }
  }

  /// Get all students
  /// GET /api/attendance/students/
  Future<List<Student>> getAllStudents() async {
    try {
      print('🔍 Fetching all students');
      final response = await _dio.get('/api/attendance/students/');
      final List<dynamic> data = response.data as List<dynamic>;
      final students = data.map((json) => Student.fromJson(json)).toList();
      print('📦 Retrieved ${students.length} students');
      return students;
    } catch (e) {
      print('❌ Error fetching all students: $e');
      rethrow;
    }
  }

  /// Upload students via CSV file
  /// POST /api/attendance/students/upload
  Future<Map<String, dynamic>> uploadStudents(FormData formData) async {
    try {
      print('📤 Uploading students CSV');
      final response = await _dio.post(
        '/api/attendance/students/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      print('✅ Upload successful: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error uploading students: $e');
      rethrow;
    }
  }

  /// Download sample CSV template
  /// GET /api/attendance/students/sample-template
  Future<List<int>> downloadSampleTemplate() async {
    try {
      print('📥 Downloading sample CSV template');
      final response = await _dio.get(
        '/api/attendance/students/sample-template',
        options: Options(responseType: ResponseType.bytes),
      );
      print('✅ Template downloaded');
      return response.data as List<int>;
    } catch (e) {
      print('❌ Error downloading template: $e');
      rethrow;
    }
  }

  /// Get students by class (with query parameters)
  /// GET /api/attendance/students/by-class?department=CSBS&year=1&section=A
  Future<List<Student>> getStudentsByClassParams({
    String? department,
    int? year,
    String? section,
  }) async {
    try {
      print('🔍 Fetching students by class params');
      final queryParams = <String, dynamic>{};
      if (department != null) queryParams['department'] = department;
      if (year != null) queryParams['year'] = year;
      if (section != null) queryParams['section'] = section;

      final response = await _dio.get(
        '/api/attendance/students/by-class',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      final students = data.map((json) => Student.fromJson(json)).toList();
      print('📦 Retrieved ${students.length} students');
      return students;
    } catch (e) {
      print('❌ Error fetching students by class: $e');
      rethrow;
    }
  }

  /// Get students by class ID
  /// GET /api/attendance/students/class/{class_id}
  Future<List<Student>> getStudentsByClassId(int classId) async {
    try {
      print('🔍 Fetching students for class ID: $classId');
      final response = await _dio.get(
        '/api/attendance/students/class/$classId',
      );
      final List<dynamic> data = response.data as List<dynamic>;
      final students = data.map((json) => Student.fromJson(json)).toList();
      print('📦 Retrieved ${students.length} students');
      return students;
    } catch (e) {
      print('❌ Error fetching students: $e');
      rethrow;
    }
  }

  /// Get a single student by ID
  /// GET /api/attendance/students/{student_id}
  Future<Student> getStudent(int studentId) async {
    try {
      print('🔍 Fetching student ID: $studentId');
      final response = await _dio.get('/api/attendance/students/$studentId');
      final student = Student.fromJson(response.data);
      print('✅ Retrieved student: ${student.name}');
      return student;
    } catch (e) {
      print('❌ Error fetching student: $e');
      rethrow;
    }
  }

  /// Delete a student
  /// DELETE /api/attendance/students/{student_id}
  Future<void> deleteStudent(int studentId) async {
    try {
      print('🗑️ Deleting student ID: $studentId');
      await _dio.delete('/api/attendance/students/$studentId');
      print('✅ Student deleted successfully');
    } catch (e) {
      print('❌ Error deleting student: $e');
      rethrow;
    }
  }

  // Legacy method for backward compatibility
  @Deprecated('Use getStudentsByClassId instead')
  Future<List<Student>> getStudentsByClass(int classId) =>
      getStudentsByClassId(classId);

  // Legacy method for backward compatibility
  @Deprecated('Use createStudent instead')
  Future<Student> addStudent(Student student) => createStudent(student);
}
