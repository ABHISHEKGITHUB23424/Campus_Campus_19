import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../auth/auth_api.dart';

// Provider for API Client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.getInstance();
});

// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.dio;
});

// Provider for Token Storage
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage.getInstance();
});

// Provider for Auth API
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthApi(dio, tokenStorage);
});

// Auth State Provider
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;

  AuthNotifier(this._authApi) : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is logged in on app start
  Future<void> _checkAuthStatus() async {
    if (_authApi.isLoggedIn()) {
      try {
        state = state.copyWith(isLoading: true);
        final user = await _authApi.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } catch (e) {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    }
  }

  /// Register new user
  Future<void> register(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _authApi.register(email, password);
      final user = await _authApi.getCurrentUser();

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Login user
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _authApi.login(email, password);
      final user = await _authApi.getCurrentUser();

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authApi.logout();
      state = AuthState(); // Reset to initial state
    } catch (e) {
      // Even if API call fails, clear local state
      state = AuthState();
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _authApi.getCurrentUser();
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider for Auth State
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authApi = ref.watch(authApiProvider);
  return AuthNotifier(authApi);
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isStudentProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isStudent ?? false;
});

final isStaffProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isStaff ?? false;
});
