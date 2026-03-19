import 'package:dio/dio.dart';
import 'package:prompt_enhancer/core/network/network_log_interceptor.dart';

const Duration _defaultConnectTimeout = Duration(seconds: 15);
const Duration _defaultSendTimeout = Duration(seconds: 15);
const Duration _defaultReceiveTimeout = Duration(seconds: 30);

Dio buildDioClient({
  String? baseUrl,
  Duration connectTimeout = _defaultConnectTimeout,
  Duration sendTimeout = _defaultSendTimeout,
  Duration receiveTimeout = _defaultReceiveTimeout,
  Iterable<Interceptor> interceptors = const [],
  bool enableLogging = true,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(NetworkLogInterceptor(enabled: enableLogging));
  dio.interceptors.addAll(interceptors);

  return dio;
}
