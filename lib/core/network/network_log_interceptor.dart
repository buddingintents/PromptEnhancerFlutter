import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class NetworkLogInterceptor extends Interceptor {
  NetworkLogInterceptor({this.enabled = true});

  final bool enabled;

  static const String _startedAtKey = 'network_request_started_at';
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'api-key',
    'apikey',
    'x-api-key',
    'token',
    'access_token',
    'refresh_token',
    'password',
    'secret',
    'client_secret',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now().microsecondsSinceEpoch;

    _log(
      'HTTP request',
      details: {
        'method': options.method,
        'uri': options.uri.toString(),
        'headers': _sanitizeMap(options.headers),
        'query': _sanitizeMap(options.queryParameters),
        'body': _sanitizeValue(options.data),
      },
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(
      'HTTP response',
      details: {
        'method': response.requestOptions.method,
        'uri': response.requestOptions.uri.toString(),
        'statusCode': response.statusCode,
        'durationMs': _resolveDurationMs(response.requestOptions),
      },
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      'HTTP error',
      details: {
        'method': err.requestOptions.method,
        'uri': err.requestOptions.uri.toString(),
        'statusCode': err.response?.statusCode,
        'type': err.type.name,
        'durationMs': _resolveDurationMs(err.requestOptions),
        'message': err.message,
      },
      error: err.error ?? err,
      stackTrace: err.stackTrace,
    );

    handler.next(err);
  }

  void _log(
    String message, {
    required Map<String, Object?> details,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enabled) {
      return;
    }

    developer.log(
      '$message: $details',
      name: 'core.network',
      error: error,
      stackTrace: stackTrace,
    );
  }

  int? _resolveDurationMs(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];

    if (startedAt is! int) {
      return null;
    }

    final elapsedMicroseconds =
        DateTime.now().microsecondsSinceEpoch - startedAt;

    return Duration(microseconds: elapsedMicroseconds).inMilliseconds;
  }

  Map<String, Object?> _sanitizeMap(Map<dynamic, dynamic> source) {
    return source.map<String, Object?>((key, value) {
      final normalizedKey = key.toString().toLowerCase();

      if (_sensitiveKeys.contains(normalizedKey)) {
        return MapEntry(key.toString(), '<redacted>');
      }

      return MapEntry(
        key.toString(),
        _sanitizeValue(value, key: normalizedKey),
      );
    });
  }

  Object? _sanitizeValue(Object? value, {String? key}) {
    if (key != null && _sensitiveKeys.contains(key.toLowerCase())) {
      return '<redacted>';
    }

    if (value is Map) {
      return _sanitizeMap(value);
    }

    if (value is Iterable) {
      return value.map((item) => _sanitizeValue(item)).toList(growable: false);
    }

    if (value is FormData) {
      return {
        'fields': value.fields.map(
          (field) =>
              MapEntry(field.key, _sanitizeValue(field.value, key: field.key)),
        ),
        'filesCount': value.files.length,
      };
    }

    if (value is String && value.length > 512) {
      return '${value.substring(0, 512)}...<trimmed>';
    }

    return value;
  }
}
