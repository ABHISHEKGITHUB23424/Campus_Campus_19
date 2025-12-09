import 'package:dio/dio.dart';
import '../models/department.dart';
import '../models/batch.dart';
import '../models/management_stats.dart';

class ManagementApi {
  final Dio _dio;

  ManagementApi(this._dio);

  // ============================================
  // Department APIs
  // ============================================

  Future<List<Department>> getDepartments() async {
    try {
      final response = await _dio.get('/api/management/departments');
      if (response.data is! List) {
        return [];
      }
      return (response.data as List)
          .map((json) => Department.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching departments: $e');
      rethrow;
    }
  }

  Future<Department> createDepartment(DepartmentCreate department) async {
    try {
      final response = await _dio.post(
        '/api/management/departments',
        data: department.toJson(),
      );
      return Department.fromJson(response.data);
    } catch (e) {
      print('❌ Error creating department: $e');
      rethrow;
    }
  }

  Future<Department> updateDepartment(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/api/management/departments/$id',
        data: data,
      );
      return Department.fromJson(response.data);
    } catch (e) {
      print('❌ Error updating department: $e');
      rethrow;
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      await _dio.delete('/api/management/departments/$id');
    } catch (e) {
      print('❌ Error deleting department: $e');
      rethrow;
    }
  }

  // ============================================
  // Batch APIs
  // ============================================

  Future<List<Batch>> getBatches() async {
    try {
      final response = await _dio.get('/api/management/batches');
      if (response.data is! List) {
        return [];
      }
      return (response.data as List)
          .map((json) => Batch.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching batches: $e');
      rethrow;
    }
  }

  Future<Batch> createBatch(BatchCreate batch) async {
    try {
      final response = await _dio.post(
        '/api/management/batches',
        data: batch.toJson(),
      );
      return Batch.fromJson(response.data);
    } catch (e) {
      print('❌ Error creating batch: $e');
      rethrow;
    }
  }

  Future<Batch> updateBatch(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/api/management/batches/$id',
        data: data,
      );
      return Batch.fromJson(response.data);
    } catch (e) {
      print('❌ Error updating batch: $e');
      rethrow;
    }
  }

  Future<void> deleteBatch(int id) async {
    try {
      await _dio.delete('/api/management/batches/$id');
    } catch (e) {
      print('❌ Error deleting batch: $e');
      rethrow;
    }
  }

  // ============================================
  // Student APIs
  // ============================================

  Future<void> createStudent(Map<String, dynamic> student) async {
    try {
      await _dio.post('/api/management/students', data: student);
    } catch (e) {
      print('❌ Error creating student: $e');
      rethrow;
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _dio.delete('/api/management/students/$id');
    } catch (e) {
      print('❌ Error deleting student: $e');
      rethrow;
    }
  }

  // ============================================
  // Statistics
  // ============================================

  Future<ManagementStats> getStats() async {
    try {
      final response = await _dio.get('/api/management/stats');
      return ManagementStats.fromJson(response.data);
    } catch (e) {
      print('❌ Error fetching stats: $e');
      rethrow;
    }
  }
}
