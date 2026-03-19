import 'package:hive_flutter/hive_flutter.dart';
import 'package:prompt_enhancer/core/storage/base_local_storage_service.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';

Future<void> initializeHive({
  Iterable<TypeAdapter<dynamic>> adapters = const [],
}) async {
  await Hive.initFlutter();

  for (final adapter in adapters) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter<dynamic>(adapter);
    }
  }
}

class HiveStorageService implements BaseLocalStorageService {
  const HiveStorageService();

  Future<Box<dynamic>> openBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<dynamic>(boxName);
      }

      return Hive.openBox<dynamic>(boxName);
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to open local storage box: $boxName',
        identifier: boxName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> write<T>({
    required String boxName,
    required String key,
    required T value,
  }) async {
    try {
      final box = await openBox(boxName);
      await box.put(key, value);
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to write data to local storage.',
        identifier: '$boxName:$key',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<T?> read<T>({required String boxName, required String key}) async {
    try {
      final box = await openBox(boxName);
      return box.get(key) as T?;
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to read data from local storage.',
        identifier: '$boxName:$key',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<T>> readAll<T>({required String boxName}) async {
    try {
      final box = await openBox(boxName);

      return box.values.whereType<T>().toList(growable: false);
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to read all data from local storage.',
        identifier: boxName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> containsKey({
    required String boxName,
    required String key,
  }) async {
    try {
      final box = await openBox(boxName);
      return box.containsKey(key);
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to check key existence in local storage.',
        identifier: '$boxName:$key',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> delete({required String boxName, required String key}) async {
    try {
      final box = await openBox(boxName);
      await box.delete(key);
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to delete data from local storage.',
        identifier: '$boxName:$key',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearBox(String boxName) async {
    try {
      final box = await openBox(boxName);
      await box.clear();
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to clear local storage box.',
        identifier: boxName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> closeBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<dynamic>(boxName).close();
      }
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to close local storage box.',
        identifier: boxName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> closeAll() async {
    try {
      await Hive.close();
    } catch (error, stackTrace) {
      throw AppException.storage(
        message: 'Failed to close local storage.',
        identifier: 'all_boxes',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
