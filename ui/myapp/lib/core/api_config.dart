/// API Configuration for Campus Connect Backend
class ApiConfig {
  // Base URL - Change this to your backend URL
  // For local development: http://localhost:8000
  // For production: https://your-production-url.com
  static const String baseUrl = 'http://localhost:8000';

  // API Version
  static const String apiVersion = 'v1';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Authentication Endpoints
  static const String authBase = '/api/auth';
  static const String register = '$authBase/register';
  static const String login = '$authBase/login';
  static const String refresh = '$authBase/refresh';
  static const String me = '$authBase/me';
  static const String logout = '$authBase/logout';
  static const String validateEmail = '$authBase/validate-email';

  // Exam Seating Endpoints
  static const String seatingBase = '/api/seating/$apiVersion';

  // Rooms
  static const String rooms = '$seatingBase/rooms';
  static const String roomsBulk = '$seatingBase/rooms/bulk';
  static const String roomsUploadCsv = '$seatingBase/rooms/upload-csv';

  // Students
  static const String students = '$seatingBase/students';
  static const String studentsBulk = '$seatingBase/students/bulk';
  static const String studentsUploadCsv = '$seatingBase/students/upload-csv';

  // Exams
  static const String exams = '$seatingBase/exams';
  static const String examsUploadCsv = '$seatingBase/exams/upload-csv';

  // Seating
  static const String seatingGenerate = '$seatingBase/seating/generate';
  static const String seatingAvailableRooms =
      '$seatingBase/seating/available-rooms';
  static const String seatingByRoom = '$seatingBase/seating/by-room';
  static const String seatingDownloadCsvByRoom =
      '$seatingBase/seating/download-csv/by-room';
  static const String seatingDownloadCsvAll =
      '$seatingBase/seating/download-csv/all';
  static const String seatingSvgByRoom = '$seatingBase/seating/svg/by-room';

  // Timetable Endpoints
  static const String timetableBase = '/api/timetable';
  static const String generateTimetable = '$timetableBase/generate_timetable';

  // Attendance Endpoints
  static const String attendanceBase = '/api/attendance';
  static const String attendanceClasses = '$attendanceBase/classes/';
  static const String attendanceStudents = '$attendanceBase/students/';
  static const String attendanceTake = '$attendanceBase/attendance/take';
  static const String attendanceCheck = '$attendanceBase/attendance/check';
  static const String attendanceByClassDate =
      '$attendanceBase/attendance/by-class-date';
  static const String attendanceStudentMonthly =
      '$attendanceBase/attendance/student-monthly';
  static const String attendanceDailySummary =
      '$attendanceBase/attendance/daily-summary';
  static const String attendanceClassSummary =
      '$attendanceBase/attendance/class-summary';

  // Occupancy Detection Endpoints
  static const String occupancyBase = '/api/occupancy';
  static const String occupancyHealth = occupancyBase;
  static const String processVideo = '$occupancyBase/process-video';
  static const String processVideoCustom =
      '$occupancyBase/process-video-custom';
  static const String downloadDebugVideo =
      '$occupancyBase/download-debug-video';

  // Health Check
  static const String health = '/health';

  // Build full URL
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';

  // Check if endpoint requires authentication
  static bool requiresAuth(String endpoint) {
    // Public endpoints (no auth required)
    final publicEndpoints = [register, login, health, validateEmail];

    return !publicEndpoints.contains(endpoint);
  }
}
