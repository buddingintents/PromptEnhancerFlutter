import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_providers.dart';
import 'package:prompt_enhancer/features/metrics/data/repositories/metrics_repository_impl.dart';
import 'package:prompt_enhancer/features/metrics/domain/repositories/metrics_repository.dart';
import 'package:prompt_enhancer/features/metrics/domain/usecases/get_usage_metrics_use_case.dart';
import 'package:prompt_enhancer/features/metrics/presentation/providers/metrics_controller.dart';
import 'package:prompt_enhancer/features/metrics/presentation/providers/metrics_state.dart';

final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  return MetricsRepositoryImpl(
    historyRepository: ref.watch(historyRepositoryProvider),
  );
});

final getUsageMetricsUseCaseProvider = Provider<GetUsageMetricsUseCase>((ref) {
  return GetUsageMetricsUseCase(ref.watch(metricsRepositoryProvider));
});

final metricsControllerProvider =
    NotifierProvider<MetricsController, MetricsState>(MetricsController.new);
