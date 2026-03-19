import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (error, stackTrace) {
      throw AppException.secureStorage(
        message: 'Failed to write secure data.',
        identifier: key,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String?> read({required String key}) async {
    try {
      return _storage.read(key: key);
    } catch (error, stackTrace) {
      throw AppException.secureStorage(
        message: 'Failed to read secure data.',
        identifier: key,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, String>> readAll() async {
    try {
      return _storage.readAll();
    } catch (error, stackTrace) {
      throw AppException.secureStorage(
        message: 'Failed to read all secure data.',
        identifier: 'all_keys',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> containsKey({required String key}) async {
    try {
      return _storage.containsKey(key: key);
    } catch (error, stackTrace) {
      throw AppException.secureStorage(
        message: 'Failed to check secure key existence.',
        identifier: key,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (error, stackTrace) {
      throw AppException.secureStorage(
        message: 'Failed to delete secure data.',
        identifier: key,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (error, stackTrace) {
      throw AppException.secureStorage(
        message: 'Failed to clear secure storage.',
        identifier: 'all_keys',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> writeAll(Map<String, String> values) async {
    try {
      for (final entry in values.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }
    } catch (error, stackTrace) {
      throw AppException.secureStorage(
        message: 'Failed to write secure data set.',
        identifier: 'batch_write',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

FlutterSecureStorage buildSecureStorage() {
  return const FlutterSecureStorage();
}
