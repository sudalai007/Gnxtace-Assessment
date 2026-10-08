import 'package:dio/dio.dart';

abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (StatusCode: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'No Internet connection available. Please check your network.']);
}

class TimeoutException extends ApiException {
  TimeoutException([super.message = 'Connection timed out. Please try again.']);
}

class ServerException extends ApiException {
  ServerException([super.message = 'Server error occurred.', super.statusCode]);
}

class RateLimitException extends ApiException {
  RateLimitException([super.message = 'API rate limit exceeded. Please wait a moment.', super.statusCode = 429]);
}

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Requested resources not found.', super.statusCode = 404]);
}

class UnknownException extends ApiException {
  UnknownException([super.message = 'An unexpected error occurred.']);
}

class ExceptionHandler {
  static ApiException handleDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode;
        if (statusCode == 429) {
          return RateLimitException();
        } else if (statusCode == 404) {
          return NotFoundException();
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException('Server error ($statusCode)', statusCode);
        }
        return ServerException(
          dioError.response?.statusMessage ?? 'Bad response from server',
          statusCode,
        );
      case DioExceptionType.cancel:
        return UnknownException('Request was cancelled');
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.unknown:
      default:
        if (dioError.message != null && dioError.message!.contains('SocketException')) {
          return NetworkException();
        }
        return UnknownException(dioError.message ?? 'Unexpected error occurred');
    }
  }
}
