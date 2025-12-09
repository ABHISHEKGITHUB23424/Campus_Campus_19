/// Configuration file for Exam Seating App
/// Set your API base URL here before running the app
class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000';

  // API Endpoints
  static const String healthEndpoint = '/health';
  static const String roomsEndpoint = '/api/seating/v1/rooms';
  static const String studentsEndpoint = '/api/seating/v1/students';
  static const String examsEndpoint = '/api/seating/v1/exams';
  static const String seatingEndpoint = '/api/seating/v1/seating';

  // App Info
  static const String appName = 'Exam Seating';
  static const String appVersion = '1.0.0';

  // Theme Colors
  static const int primaryColor = 0xFF00ADB5; // Cyan accent
  static const int darkColor = 0xFF222831;
  static const int lightColor = 0xFFEEEEEE;
  static const int neutralColor = 0xFF393E46;
}
