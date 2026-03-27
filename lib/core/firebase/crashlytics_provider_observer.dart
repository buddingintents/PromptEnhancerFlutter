import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/firebase/firebase_telemetry_service.dart';

final class CrashlyticsProviderObserver extends ProviderObserver {
  const CrashlyticsProviderObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    unawaited(
      FirebaseTelemetryService.reportError(
        error,
        stackTrace,
        reason: 'riverpod_provider_error',
        customKeys: {
          'provider':
              context.provider.name ?? context.provider.runtimeType.toString(),
          'container': context.container.runtimeType.toString(),
        },
      ),
    );

    super.providerDidFail(context, error, stackTrace);
  }
}
