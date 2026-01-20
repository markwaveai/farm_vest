/// A set of custom exception classes to handle different error scenarios in the app.

/// Base class for all custom exceptions in the app.
class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() => prefix != null ? '$prefix: $message' : message;
}

/// Exception for errors that occur during communication with an API.
class ServerException extends AppException {
  final int? statusCode;

  ServerException(String message, {this.statusCode})
      : super(message, 'Server Error');
}

/// Exception for network-related errors, such as no internet connection.
class NetworkException extends AppException {
  NetworkException(String message) : super(message, 'Network Error');
}

/// Exception for errors related to local data caching.
class CacheException extends AppException {
  CacheException(String message) : super(message, 'Cache Error');
}

/// Exception for when an authentication token is not found or is invalid.
class AuthException extends AppException {
  AuthException(String message) : super(message, 'Authentication Error');
}
