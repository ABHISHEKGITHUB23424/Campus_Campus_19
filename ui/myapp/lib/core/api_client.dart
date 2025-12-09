import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'api_config.dart';
import 'token_storage.dart';

/// Singleton API Client with authentication interceptor
class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;
  late TokenStorage _tokenStorage;
  bool _isInitialized = false;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
  }

  /// Get singleton instance (synchronous after initialization)
  static ApiClient getInstance() {
    if (_instance == null || !_instance!._isInitialized) {
      throw StateError(
        'ApiClient not initialized. Call ApiClient.initialize() before using getInstance().',
      );
    }
    return _instance!;
  }

  /// Initialize the API client (must be called before getInstance)
  static Future<ApiClient> initialize() async {
    if (_instance == null) {
      _instance = ApiClient._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  /// Initialize token storage and interceptors
  Future<void> _initialize() async {
    if (!_isInitialized) {
      _tokenStorage = await TokenStorage.getInstance();
      _setupInterceptors();
      _isInitialized = true;
    }
  }

  /// Setup interceptors for authentication and error handling
  void _setupInterceptors() {
    // Clear any existing interceptors
    _dio.interceptors.clear();

    // Authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header if token exists and endpoint requires auth
          final token = _tokenStorage.getAccessToken();

          if (token != null && ApiConfig.requiresAuth(options.path)) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('🔵 REQUEST: ${options.method} ${options.uri}');
          print('   Headers: ${options.headers}');
          if (options.data != null) {
            print('   Body: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          print('   Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ ERROR: ${error.type} ${error.message}');
          print('   Response: ${error.response?.data}');

          // Handle 401 Unauthorized - try to refresh token
          if (error.response?.statusCode == 401) {
            final refreshToken = _tokenStorage.getRefreshToken();

            if (refreshToken != null &&
                !error.requestOptions.path.contains('/refresh')) {
              try {
                print('🔄 Attempting to refresh token...');

                // Try to refresh the access token
                final refreshResponse = await _dio.post(
                  ApiConfig.refresh,
                  data: {'refresh_token': refreshToken},
                  options: Options(
                    headers: {
                      'Authorization': null, // Don't send old token
                    },
                  ),
                );

                // Save new tokens
                await _tokenStorage.saveTokens(
                  accessToken: refreshResponse.data['access_token'],
                  refreshToken: refreshResponse.data['refresh_token'],
                );

                print('✅ Token refreshed successfully');

                // Retry original request with new token
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization':
                        'Bearer ${refreshResponse.data['access_token']}',
                  },
                );

                final retryResponse = await _dio.request(
                  error.requestOptions.path,
                  options: opts,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );

                return handler.resolve(retryResponse);
              } catch (refreshError) {
                print('❌ Token refresh failed, clearing tokens');
                // Refresh failed, clear tokens and propagate error
                await _tokenStorage.clearAll();
              }
            } else if (refreshToken == null) {
              print('❌ No refresh token available');
            }
          }

          return handler.reject(_handleDioError(error));
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Handle Dio errors and convert to custom exceptions
  DioException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 400) {
          String message = 'Bad request';
          if (data is Map && data.containsKey('detail')) {
            message = data['detail'].toString();
          }
          throw ValidationException(message, errors: data);
        } else if (statusCode == 401) {
          throw UnauthorizedException();
        } else if (statusCode == 404) {
          throw NotFoundException();
        } else if (statusCode != null && statusCode >= 500) {
          throw ServerException();
        }

        String message = 'Request failed';
        if (data is Map && data.containsKey('detail')) {
          message = data['detail'].toString();
        }
        throw ApiException(message, statusCode: statusCode, data: data);

      case DioExceptionType.cancel:
        throw ApiException('Request cancelled');

      case DioExceptionType.connectionError:
        throw NetworkException('No internet connection');

      case DioExceptionType.badCertificate:
        throw NetworkException('Security certificate error');

      case DioExceptionType.unknown:
        throw NetworkException('Unknown error occurred');
    }
  }
}
