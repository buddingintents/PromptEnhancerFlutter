import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';

class ApiErrorMapper {
  const ApiErrorMapper();

  AppException map(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _mapDioException(error, stackTrace);
    }

    if (error is HiveError) {
      return AppException.storage(
        message: error.message,
        identifier: 'hive_error',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return AppException.unknown(
      message: error.toString(),
      identifier: 'unknown_error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  AppException _mapDioException(DioException error, StackTrace? stackTrace) {
    final statusCode = error.response?.statusCode;
    final message = _extractMessage(error);
    final requestPath = error.requestOptions.path;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException.timeout(
          message: message,
          identifier: requestPath,
          error: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return AppException.network(
          message: message,
          statusCode: statusCode,
          identifier: requestPath,
          error: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(
          statusCode: statusCode,
          message: message,
          identifier: requestPath,
          error: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
        return AppException.network(
          message: 'The request was cancelled.',
          statusCode: statusCode,
          identifier: requestPath,
          error: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.unknown:
        return AppException.network(
          message: message,
          statusCode: statusCode,
          identifier: requestPath,
          error: error,
          stackTrace: stackTrace,
        );
    }
  }

  AppException _mapStatusCode({
    required int? statusCode,
    required String message,
    required String identifier,
    required DioException error,
    StackTrace? stackTrace,
  }) {
    switch (statusCode) {
      case 400:
      case 422:
        return AppException.validation(
          message: message,
          statusCode: statusCode,
          identifier: identifier,
          error: error,
          stackTrace: stackTrace,
        );
      case 401:
        return AppException.unauthorized(
          message: message,
          statusCode: statusCode,
          identifier: identifier,
          error: error,
          stackTrace: stackTrace,
        );
      case 403:
        return AppException.forbidden(
          message: message,
          statusCode: statusCode,
          identifier: identifier,
          error: error,
          stackTrace: stackTrace,
        );
      case 404:
        return AppException.notFound(
          message: message,
          statusCode: statusCode,
          identifier: identifier,
          error: error,
          stackTrace: stackTrace,
        );
      case 408:
        return AppException.timeout(
          message: message,
          identifier: identifier,
          error: error,
          stackTrace: stackTrace,
        );
      case 409:
        return AppException.conflict(
          message: message,
          statusCode: statusCode,
          identifier: identifier,
          error: error,
          stackTrace: stackTrace,
        );
      default:
        return AppException.server(
          message: message,
          statusCode: statusCode,
          identifier: identifier,
          error: error,
          stackTrace: stackTrace,
        );
    }
  }

  String _extractMessage(DioException error) {
    const fallbackMessage = 'Unable to complete the request.';
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'detail', 'title']) {
        final value = responseData[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
    }

    if (responseData is Map) {
      for (final key in ['message', 'error', 'detail', 'title']) {
        final value = responseData[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The request timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection or the server is unreachable.';
      case DioExceptionType.badCertificate:
        return 'The server certificate could not be verified.';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      case DioExceptionType.badResponse:
        return fallbackMessage;
      case DioExceptionType.unknown:
        return error.message ?? fallbackMessage;
    }
  }
}
