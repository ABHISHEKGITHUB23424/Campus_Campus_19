import 'package:dio/dio.dart';
import '../core/api_config.dart';
import '../core/token_storage.dart';

/// User model for authentication
class User {
  final int id;
  final String email;
  final String role; // 'student' or 'staff'
  final String? studentName;
  final String? department;
  final int? batchYear;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.studentName,
    this.department,
    this.batchYear,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      studentName: json['student_name'],
      department: json['department'],
      batchYear: json['batch_year'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'student_name': studentName,
      'department': department,
      'batch_year': batchYear,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isStudent => role == 'student';
  bool get isStaff => role == 'staff';
}

/// Authentication response model
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
    );
  }
}

/// Authentication API service with JWT-based authentication
class AuthApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthApi(this._dio, this._tokenStorage);

  /// Register a new user
  /// Email must be @citchennai.net
  /// Student emails: name.deptYYYY@citchennai.net (e.g., john.csbs2023@citchennai.net)
  /// Staff emails: any @citchennai.net email
  Future<AuthResponse> register(String email, String password) async {
    try {
      print('📝 Registering user: $email');

      final response = await _dio.post(
        ApiConfig.register,
        data: {'email': email, 'password': password},
      );

      print('✅ Registration successful');
      final authResponse = AuthResponse.fromJson(response.data);

      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        email: email,
      );

      return authResponse;
    } on DioException catch (e) {
      print('❌ Registration Error: ${e.message}');
      if (e.response?.statusCode == 400) {
        final detail =
            e.response?.data['detail'] ?? 'Invalid registration data';
        throw Exception(detail);
      }
      throw Exception('Failed to register: ${e.message}');
    }
  }

  /// Login with email and password
  /// Returns JWT tokens
  Future<AuthResponse> login(String email, String password) async {
    try {
      print('🔐 Logging in: $email');

      final response = await _dio.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      print('✅ Login successful');
      final authResponse = AuthResponse.fromJson(response.data);

      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        email: email,
      );

      return authResponse;
    } on DioException catch (e) {
      print('❌ Login Error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (e.response?.statusCode == 400) {
        final detail = e.response?.data['detail'] ?? 'Invalid login data';
        throw Exception(detail);
      }
      throw Exception('Failed to login: ${e.message}');
    }
  }

  /// Refresh access token using refresh token
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = _tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      print('🔄 Refreshing token');

      final response = await _dio.post(
        ApiConfig.refresh,
        data: {'refresh_token': refreshToken},
      );

      print('✅ Token refreshed');
      final authResponse = AuthResponse.fromJson(response.data);

      // Save new tokens
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } on DioException catch (e) {
      print('❌ Token Refresh Error: ${e.message}');
      await _tokenStorage.clearAll();
      throw Exception('Failed to refresh token: ${e.message}');
    }
  }

  /// Get current user profile
  /// Requires valid access token
  Future<User> getCurrentUser() async {
    try {
      print('👤 Fetching current user');

      final response = await _dio.get(ApiConfig.me);

      print('✅ User profile fetched');
      final user = User.fromJson(response.data);

      // Save user role
      await _tokenStorage.saveUserRole(user.role);

      return user;
    } on DioException catch (e) {
      print('❌ Get User Error: ${e.message}');
      throw Exception('Failed to get user profile: ${e.message}');
    }
  }

  /// Logout user
  /// Clears all stored tokens
  Future<void> logout() async {
    try {
      print('👋 Logging out');

      // Call logout endpoint (optional, since JWT is stateless)
      await _dio.post(ApiConfig.logout);

      // Clear local tokens
      await _tokenStorage.clearAll();

      print('✅ Logged out successfully');
    } on DioException catch (e) {
      print('❌ Logout Error: ${e.message}');
      // Still clear tokens even if API call fails
      await _tokenStorage.clearAll();
    }
  }

  /// Validate email format (testing endpoint)
  Future<Map<String, dynamic>> validateEmail(String email) async {
    try {
      print('✉️ Validating email: $email');

      final response = await _dio.get(
        ApiConfig.validateEmail,
        queryParameters: {'email': email},
      );

      print('✅ Email validation response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Email Validation Error: ${e.message}');
      throw Exception('Failed to validate email: ${e.message}');
    }
  }

  /// Check if user is currently logged in
  bool isLoggedIn() {
    return _tokenStorage.isLoggedIn();
  }

  /// Get stored user email
  String? getUserEmail() {
    return _tokenStorage.getUserEmail();
  }

  /// Get stored user role
  String? getUserRole() {
    return _tokenStorage.getUserRole();
  }
}
