import 'package:shared_preferences/shared_preferences.dart';

/// Secure token storage service using SharedPreferences
class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  static TokenStorage? _instance;
  late SharedPreferences _prefs;

  TokenStorage._();

  /// Get singleton instance (synchronous after initialization)
  static TokenStorage getInstance() {
    if (_instance == null) {
      throw StateError(
        'TokenStorage not initialized. Call TokenStorage.initialize() before using getInstance().',
      );
    }
    return _instance!;
  }

  /// Initialize token storage (must be called before getInstance)
  static Future<TokenStorage> initialize() async {
    if (_instance == null) {
      _instance = TokenStorage._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Access Token methods
  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(_accessTokenKey, token);
  }

  String? getAccessToken() {
    return _prefs.getString(_accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _prefs.remove(_accessTokenKey);
  }

  // Refresh Token methods
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _prefs.remove(_refreshTokenKey);
  }

  // User Info methods
  Future<void> saveUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }

  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  Future<void> saveUserRole(String role) async {
    await _prefs.setString(_userRoleKey, role);
  }

  String? getUserRole() {
    return _prefs.getString(_userRoleKey);
  }

  // Save all tokens at once
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? email,
    String? role,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    if (email != null) await saveUserEmail(email);
    if (role != null) await saveUserRole(role);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getAccessToken() != null;
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userRoleKey);
  }

  // Get all stored data (for debugging)
  Map<String, String?> getAllData() {
    return {
      'accessToken': getAccessToken(),
      'refreshToken': getRefreshToken(),
      'email': getUserEmail(),
      'role': getUserRole(),
    };
  }
}
