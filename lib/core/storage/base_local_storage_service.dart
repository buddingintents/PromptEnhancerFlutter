abstract class BaseLocalStorageService {
  Future<void> write<T>({
    required String boxName,
    required String key,
    required T value,
  });

  Future<T?> read<T>({required String boxName, required String key});

  Future<List<T>> readAll<T>({required String boxName});

  Future<bool> containsKey({required String boxName, required String key});

  Future<void> delete({required String boxName, required String key});

  Future<void> clearBox(String boxName);

  Future<void> closeBox(String boxName);

  Future<void> closeAll();
}
