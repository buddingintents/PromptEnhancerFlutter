import 'package:prompt_enhancer/features/settings/domain/services/biometric_guard.dart';

class MockBiometricGuard implements BiometricGuard {
  const MockBiometricGuard();

  @override
  Future<bool> authenticate({required String reason}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return true;
  }
}
