/// Custom exceptions for the application
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException(this.message, {this.errors});

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => 'NotFoundException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Unauthorized access']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ServerException implements Exception {
  final String message;

  ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}
