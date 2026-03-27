import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:prompt_enhancer/core/storage/secure_storage_service.dart';

class DeviceIdentityService {
  DeviceIdentityService({
    required SecureStorageService secureStorage,
    DeviceInfoPlugin? deviceInfo,
  }) : _secureStorage = secureStorage,
       _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  static const String _deviceIdKey = 'device_identity.id';

  final SecureStorageService _secureStorage;
  final DeviceInfoPlugin _deviceInfo;

  Future<DeviceIdentitySnapshot> getSnapshot() async {
    final deviceId = await getDeviceId();
    final deviceModel = await getDeviceModel();
    return DeviceIdentitySnapshot(deviceId: deviceId, deviceModel: deviceModel);
  }

  Future<String> getDeviceId() async {
    final existingValue = await _secureStorage.read(key: _deviceIdKey);
    final normalizedExistingValue = existingValue?.trim() ?? '';
    if (normalizedExistingValue.isNotEmpty) {
      return normalizedExistingValue;
    }

    final generatedId = _generateDeviceId();
    await _secureStorage.write(key: _deviceIdKey, value: generatedId);
    return generatedId;
  }

  Future<String> getDeviceModel() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        final browserName = webInfo.browserName.name;
        return 'Web ($browserName)';
      }

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final manufacturer = androidInfo.manufacturer.trim();
        final model = androidInfo.model.trim();
        return _joinParts([manufacturer, model], fallback: 'Android Device');
      }

      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return _joinParts([
          iosInfo.name.trim(),
          iosInfo.model.trim(),
        ], fallback: 'iPhone');
      }

      if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return _joinParts([
          windowsInfo.computerName.trim(),
          'Windows',
        ], fallback: 'Windows Device');
      }

      if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return _joinParts([macInfo.model.trim(), 'macOS'], fallback: 'Mac');
      }

      if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        final version = linuxInfo.version ?? '';
        return _joinParts([
          linuxInfo.name.trim(),
          version.trim(),
        ], fallback: 'Linux Device');
      }
    } catch (_) {}

    return 'Unknown Device';
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return values
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  String _joinParts(List<String> parts, {required String fallback}) {
    final normalizedParts = parts
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (normalizedParts.isEmpty) {
      return fallback;
    }

    return normalizedParts.join(' ');
  }
}

class DeviceIdentitySnapshot {
  const DeviceIdentitySnapshot({
    required this.deviceId,
    required this.deviceModel,
  });

  final String deviceId;
  final String deviceModel;
}
