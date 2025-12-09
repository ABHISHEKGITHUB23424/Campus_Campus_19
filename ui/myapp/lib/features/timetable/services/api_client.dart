import 'package:dio/dio.dart';

/// Simple API client for timetable service
class ApiClient {
  final Dio dio;

  ApiClient({String baseUrl = 'http://localhost:8000'})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
}
