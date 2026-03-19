import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/network/api_error_mapper.dart';
import 'package:prompt_enhancer/core/network/dio_client.dart';
import 'package:prompt_enhancer/core/storage/base_local_storage_service.dart';
import 'package:prompt_enhancer/core/storage/hive_storage_service.dart';
import 'package:prompt_enhancer/core/storage/secure_storage_service.dart';

final apiErrorMapperProvider = Provider<ApiErrorMapper>((ref) {
  return const ApiErrorMapper();
});

final dioProvider = Provider<Dio>((ref) {
  return buildDioClient(
    enableLogging: !const bool.fromEnvironment('dart.vm.product'),
  );
});

final baseLocalStorageProvider = Provider<BaseLocalStorageService>((ref) {
  return ref.watch(hiveStorageProvider);
});

final hiveStorageProvider = Provider<HiveStorageService>((ref) {
  return const HiveStorageService();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(storage: buildSecureStorage());
});
