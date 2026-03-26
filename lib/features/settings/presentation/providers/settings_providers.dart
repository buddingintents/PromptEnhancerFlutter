import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/di/core_providers.dart';
import 'package:prompt_enhancer/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:prompt_enhancer/features/settings/data/services/mock_biometric_guard.dart';
import 'package:prompt_enhancer/features/settings/domain/repositories/settings_repository.dart';
import 'package:prompt_enhancer/features/settings/domain/services/biometric_guard.dart';
import 'package:prompt_enhancer/features/settings/domain/usecases/delete_provider_api_key_use_case.dart';
import 'package:prompt_enhancer/features/settings/domain/usecases/get_settings_snapshot_use_case.dart';
import 'package:prompt_enhancer/features/settings/domain/usecases/save_provider_api_key_use_case.dart';
import 'package:prompt_enhancer/features/settings/domain/usecases/update_language_preference_use_case.dart';
import 'package:prompt_enhancer/features/settings/domain/usecases/update_preferred_provider_use_case.dart';
import 'package:prompt_enhancer/features/settings/domain/usecases/update_provider_model_use_case.dart';
import 'package:prompt_enhancer/features/settings/domain/usecases/update_theme_preference_use_case.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_controller.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_state.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    localStorage: ref.watch(baseLocalStorageProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final biometricGuardProvider = Provider<BiometricGuard>((ref) {
  return const MockBiometricGuard();
});

final getSettingsSnapshotUseCaseProvider = Provider<GetSettingsSnapshotUseCase>(
  (ref) {
    return GetSettingsSnapshotUseCase(ref.watch(settingsRepositoryProvider));
  },
);

final saveProviderApiKeyUseCaseProvider = Provider<SaveProviderApiKeyUseCase>((
  ref,
) {
  return SaveProviderApiKeyUseCase(ref.watch(settingsRepositoryProvider));
});

final deleteProviderApiKeyUseCaseProvider =
    Provider<DeleteProviderApiKeyUseCase>((ref) {
      return DeleteProviderApiKeyUseCase(ref.watch(settingsRepositoryProvider));
    });

final updateProviderModelUseCaseProvider = Provider<UpdateProviderModelUseCase>(
  (ref) {
    return UpdateProviderModelUseCase(ref.watch(settingsRepositoryProvider));
  },
);

final updateThemePreferenceUseCaseProvider =
    Provider<UpdateThemePreferenceUseCase>((ref) {
      return UpdateThemePreferenceUseCase(
        ref.watch(settingsRepositoryProvider),
      );
    });

final updateLanguagePreferenceUseCaseProvider =
    Provider<UpdateLanguagePreferenceUseCase>((ref) {
      return UpdateLanguagePreferenceUseCase(
        ref.watch(settingsRepositoryProvider),
      );
    });

final updatePreferredProviderUseCaseProvider =
    Provider<UpdatePreferredProviderUseCase>((ref) {
      return UpdatePreferredProviderUseCase(
        ref.watch(settingsRepositoryProvider),
      );
    });

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
