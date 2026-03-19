enum AppExceptionType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  conflict,
  server,
  storage,
  secureStorage,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.message,
    required this.type,
    this.code,
    this.statusCode,
    this.identifier,
    this.error,
    this.stackTrace,
  });

  final String message;
  final AppExceptionType type;
  final String? code;
  final int? statusCode;
  final String? identifier;
  final Object? error;
  final StackTrace? stackTrace;

  factory AppException.network({
    required String message,
    int? statusCode,
    String? code,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.network,
      statusCode: statusCode,
      code: code,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.timeout({
    String message = 'The request timed out. Please try again.',
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.timeout,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.unauthorized({
    String message = 'You are not authorized to perform this action.',
    int? statusCode,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.unauthorized,
      statusCode: statusCode,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.forbidden({
    String message = 'Access to this resource is forbidden.',
    int? statusCode,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.forbidden,
      statusCode: statusCode,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.notFound({
    String message = 'The requested resource was not found.',
    int? statusCode,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.notFound,
      statusCode: statusCode,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.validation({
    required String message,
    int? statusCode,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.validation,
      statusCode: statusCode,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.conflict({
    required String message,
    int? statusCode,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.conflict,
      statusCode: statusCode,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.server({
    String message = 'A server error occurred. Please try again later.',
    int? statusCode,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.server,
      statusCode: statusCode,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.storage({
    required String message,
    String? code,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.storage,
      code: code,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.secureStorage({
    required String message,
    String? code,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.secureStorage,
      code: code,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppException.unknown({
    String message = 'Something went wrong. Please try again.',
    String? code,
    String? identifier,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: AppExceptionType.unknown,
      code: code,
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    return 'AppException(type: $type, message: $message, '
        'statusCode: $statusCode, code: $code, identifier: $identifier)';
  }
}
