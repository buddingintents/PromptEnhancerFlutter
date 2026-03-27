import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/firebase/firebase_telemetry_service.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/metrics/presentation/providers/metrics_providers.dart';
import 'package:prompt_enhancer/features/metrics/presentation/providers/metrics_state.dart';

class MetricsController extends Notifier<MetricsState> {
  @override
  MetricsState build() {
    Future.microtask(loadMetrics);
    return const MetricsState(loading: true);
  }

  Future<void> loadMetrics() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final summary = await ref.read(getUsageMetricsUseCaseProvider)();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(summary: summary, loading: false, error: null);
    } catch (error, stackTrace) {
      await FirebaseTelemetryService.reportError(
        error,
        stackTrace,
        reason: 'metrics_load_failed',
      );
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(loading: false, error: _mapError(error));
    }
  }

  String _mapError(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return 'Unable to load usage metrics right now.';
  }
}
