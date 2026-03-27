import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/core/firebase/firebase_telemetry_service.dart';
import 'package:prompt_enhancer/features/trending/presentation/providers/trending_providers.dart';
import 'package:prompt_enhancer/features/trending/presentation/providers/trending_state.dart';

class TrendingController extends Notifier<TrendingState> {
  @override
  TrendingState build() {
    Future.microtask(loadTrendingTopics);
    return const TrendingState(loading: true);
  }

  Future<void> loadTrendingTopics() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final topics = await ref.read(getTrendingTopicsUseCaseProvider)();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(topics: topics, loading: false, error: null);
    } catch (error, stackTrace) {
      await FirebaseTelemetryService.reportError(
        error,
        stackTrace,
        reason: 'trending_load_failed',
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

    return 'Unable to analyze local history right now.';
  }
}
