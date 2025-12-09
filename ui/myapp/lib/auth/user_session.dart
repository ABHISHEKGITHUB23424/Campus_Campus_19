import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// User session management with JWT token and profile storage
class UserSession {
  static const String _tokenKey = 'auth_token';
  static const String _profileKey = 'user_profile';

  /// Save authentication token and user profile
  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> profile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_profileKey, json.encode(profile));
    print('✅ Session saved for: ${profile['email']}');
  }

  /// Get stored authentication token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get stored user profile
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString(_profileKey);
    if (profileStr == null) return null;
    return json.decode(profileStr);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get user type (student or staff)
  static Future<String?> getUserType() async {
    final profile = await getProfile();
    return profile?['user_type'];
  }

  /// Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_profileKey);
    print('🔓 Session cleared');
  }

  /// Get user email
  static Future<String?> getEmail() async {
    final profile = await getProfile();
    return profile?['email'];
  }

  /// Get department (for students only)
  static Future<String?> getDepartment() async {
    final profile = await getProfile();
    return profile?['department'];
  }

  /// Get batch (for students only)
  static Future<String?> getBatch() async {
    final profile = await getProfile();
    return profile?['batch'];
  }
}
