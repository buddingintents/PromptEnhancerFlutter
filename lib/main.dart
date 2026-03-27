import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/app/app.dart';
import 'package:prompt_enhancer/core/firebase/crashlytics_provider_observer.dart';
import 'package:prompt_enhancer/core/firebase/firebase_bootstrap.dart';
import 'package:prompt_enhancer/core/firebase/firebase_telemetry_service.dart';
import 'package:prompt_enhancer/core/storage/hive_storage_service.dart';
import 'package:prompt_enhancer/features/history/data/models/history_item.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initializeFirebaseServices();
      await initializeHive(adapters: [HistoryItemAdapter()]);

      runApp(
        ProviderScope(
          observers: const [CrashlyticsProviderObserver()],
          child: const PromptEnhancerApp(),
        ),
      );
    },
    (error, stackTrace) {
      unawaited(
        FirebaseTelemetryService.reportError(
          error,
          stackTrace,
          reason: 'run_zoned_guarded_error',
          fatal: true,
        ),
      );
    },
  );
}
