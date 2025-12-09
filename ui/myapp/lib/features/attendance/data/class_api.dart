import 'package:dio/dio.dart';
import 'models/class_model.dart';

/// API service for class-related operations
class ClassApi {
  final Dio _dio;

  ClassApi(this._dio);

  /// Get all classes
  /// GET /api/attendance/classes/
  Future<List<ClassModel>> getAllClasses() async {
    try {
      print('🔍 Fetching all classes');
      final response = await _dio.get('/api/attendance/classes/');
      final List<dynamic> data = response.data as List<dynamic>;
      final classes = data.map((json) => ClassModel.fromJson(json)).toList();
      print('📦 Retrieved ${classes.length} classes');
      return classes;
    } catch (e) {
      print('❌ Error fetching classes: $e');
      rethrow;
    }
  }

  /// Create a new class
  /// POST /api/attendance/classes/
  Future<ClassModel> createClass(ClassModel classModel) async {
    try {
      print('➕ Creating class: ${classModel.displayName}');
      final response = await _dio.post(
        '/api/attendance/classes/',
        data: classModel.toJson(),
      );
      final newClass = ClassModel.fromJson(response.data);
      print('✅ Class created with ID: ${newClass.id}');
      return newClass;
    } catch (e) {
      print('❌ Error creating class: $e');
      rethrow;
    }
  }

  /// Get class by ID
  /// GET /api/attendance/classes/{class_id}
  Future<ClassModel> getClass(int classId) async {
    try {
      print('🔍 Fetching class ID: $classId');
      final response = await _dio.get('/api/attendance/classes/$classId');
      final classModel = ClassModel.fromJson(response.data);
      print('✅ Retrieved class: ${classModel.displayName}');
      return classModel;
    } catch (e) {
      print('❌ Error fetching class: $e');
      rethrow;
    }
  }

  /// Delete a class
  /// DELETE /api/attendance/classes/{class_id}
  Future<void> deleteClass(int classId) async {
    try {
      print('🗑️ Deleting class ID: $classId');
      await _dio.delete('/api/attendance/classes/$classId');
      print('✅ Class deleted successfully');
    } catch (e) {
      print('❌ Error deleting class: $e');
      rethrow;
    }
  }

  /// Get class by details (department, year, section)
  /// GET /api/attendance/classes/search/by-details?department=CSBS&year=1&section=A
  Future<ClassModel> getClassByDetails({
    required String department,
    required int year,
    required String section,
  }) async {
    try {
      print('🔍 Searching class: $department-$year-$section');
      final response = await _dio.get(
        '/api/attendance/classes/search/by-details',
        queryParameters: {
          'department': department,
          'year': year,
          'section': section,
        },
      );
      final classModel = ClassModel.fromJson(response.data);
      print('✅ Found class: ${classModel.displayName}');
      return classModel;
    } catch (e) {
      print('❌ Error searching class: $e');
      rethrow;
    }
  }

  /// Map students to a class
  /// PUT /api/attendance/classes/{class_id}/map-students
  Future<Map<String, dynamic>> mapStudentsToClass({
    required int classId,
    required List<int> studentIds,
  }) async {
    try {
      print('🔗 Mapping ${studentIds.length} students to class $classId');
      final response = await _dio.put(
        '/api/attendance/classes/$classId/map-students',
        data: {'student_ids': studentIds},
      );
      print('✅ Students mapped successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error mapping students: $e');
      rethrow;
    }
  }

  // Legacy methods for backward compatibility
  @Deprecated('Use getAllClasses instead')
  Future<List<ClassModel>> getClasses() => getAllClasses();

  @Deprecated('Use getClass instead')
  Future<ClassModel> getClassById(int classId) => getClass(classId);
}
