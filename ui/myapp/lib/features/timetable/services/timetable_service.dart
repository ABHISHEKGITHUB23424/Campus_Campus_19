import 'api_client.dart';

/// Service for timetable generation API calls
class TimetableService {
  final ApiClient _apiClient;

  TimetableService(this._apiClient);

  /// Generate timetable by calling backend endpoint
  Future<dynamic> generateTimetable({
    required List<Map<String, dynamic>> departments,
    required List<dynamic> timeslots,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/timetable/generate',
        data: {'departments': departments, 'timeslots': timeslots},
      );

      return response.data;
    } catch (e) {
      print('❌ Error generating timetable: $e');
      rethrow;
    }
  }
}
