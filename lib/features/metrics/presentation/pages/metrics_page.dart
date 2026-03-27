import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/constants/admob_constants.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/daily_prompt_metric.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/provider_latency_metric.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/provider_token_metric.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/usage_metrics_summary.dart';
import 'package:prompt_enhancer/features/metrics/presentation/providers/metrics_providers.dart';
import 'package:prompt_enhancer/shared/widgets/app_banner_ad_slot.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/app_state_view.dart';

class MetricsPage extends ConsumerWidget {
  const MetricsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(metricsControllerProvider);
    final controller = ref.read(metricsControllerProvider.notifier);
    final theme = Theme.of(context);

    return AppShellScaffold(
      title: 'Metrics',
      currentRoute: AppRoutes.metrics,
      child: RefreshIndicator(
        onRefresh: controller.loadMetrics,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1120;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppCard(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Metrics',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Monitor how prompts are used across providers with token totals, response time trends, and prompts-per-day analytics generated from local history.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (state.loading && !state.summary.hasData)
                  AppStateView.loading(
                    title: 'Preparing Metrics',
                    message:
                        'Crunching local history to build charts and provider summaries.',
                  )
                else if (state.error != null)
                  AppStateView.error(
                    title: 'Metrics Unavailable',
                    message: state.error!,
                    actionLabel: 'Retry',
                    onAction: controller.loadMetrics,
                  )
                else if (!state.summary.hasData)
                  AppStateView.empty(
                    title: 'No Metrics Yet',
                    message:
                        'Refine a few prompts to start building provider usage charts and performance insights.',
                  )
                else ...[
                  _SummarySection(summary: state.summary),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _TokensByProviderChart(summary: state.summary),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 5,
                          child: _LatencyBreakdownCard(summary: state.summary),
                        ),
                      ],
                    )
                  else ...[
                    _TokensByProviderChart(summary: state.summary),
                    const SizedBox(height: 24),
                    _LatencyBreakdownCard(summary: state.summary),
                  ],
                  const SizedBox(height: 24),
                  _PromptsPerDayChart(summary: state.summary),
                ],
                const SizedBox(height: 24),
                AppBannerAdSlot(
                  adUnitId: AdMobConstants.bannerUnitIdFor(AppRoutes.metrics),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final UsageMetricsSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Overview',
      subtitle:
          'Total prompts, token volume, and average response time in one place.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRow = constraints.maxWidth >= 760;
          final metrics = [
            _SummaryMetric(
              label: 'Total Prompts',
              value: '${summary.totalPrompts}',
              icon: Icons.notes_outlined,
            ),
            _SummaryMetric(
              label: 'Total Tokens',
              value: '${summary.totalTokens}',
              icon: Icons.tune_outlined,
            ),
            _SummaryMetric(
              label: 'Avg Response Time',
              value: summary.averageResponseTimeMs > 0
                  ? '${summary.averageResponseTimeMs.toStringAsFixed(0)} ms'
                  : 'N/A',
              icon: Icons.timer_outlined,
            ),
          ];

          if (!useRow) {
            return Column(
              children: [
                for (var index = 0; index < metrics.length; index++) ...[
                  metrics[index],
                  if (index != metrics.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          }

          return IntrinsicHeight(
            child: Row(
              children: [
                for (var index = 0; index < metrics.length; index++) ...[
                  Expanded(child: metrics[index]),
                  if (index != metrics.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: VerticalDivider(width: 1),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _TokensByProviderChart extends StatelessWidget {
  const _TokensByProviderChart({required this.summary});

  final UsageMetricsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = summary.providerTokenMetrics;
    final maxY = _maxTokenValue(metrics);

    return AppCard(
      title: 'Total Tokens Per Provider',
      subtitle: 'A bar chart generated from saved history entries.',
      child: SizedBox(
        height: 320,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY <= 5 ? 1 : maxY / 4,
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.toStringAsFixed(0),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= metrics.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _compactProvider(metrics[index].provider),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var index = 0; index < metrics.length; index++)
                BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: metrics[index].totalTokens.toDouble(),
                      width: 28,
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptsPerDayChart extends StatelessWidget {
  const _PromptsPerDayChart({required this.summary});

  final UsageMetricsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = summary.promptsPerDay;
    final maxY = _maxPromptCount(metrics);
    final spots = [
      for (var index = 0; index < metrics.length; index++)
        FlSpot(index.toDouble(), metrics[index].promptCount.toDouble()),
    ];

    return AppCard(
      title: 'Prompts Per Day',
      subtitle: 'A line chart showing how often prompts were refined each day.',
      child: SizedBox(
        height: 320,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: math.max(0, metrics.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY <= 5 ? 1 : maxY / 4,
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      value.toStringAsFixed(0),
                      style: theme.textTheme.bodySmall,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _bottomTitleInterval(metrics.length),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= metrics.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _formatDay(metrics[index].date),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: theme.colorScheme.tertiary,
                dotData: FlDotData(show: spots.length <= 10),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatencyBreakdownCard extends StatelessWidget {
  const _LatencyBreakdownCard({required this.summary});

  final UsageMetricsSummary summary;

  @override
  Widget build(BuildContext context) {
    final latencies = summary.providerLatencyMetrics;

    return AppCard(
      title: 'Average Response Time',
      subtitle: 'Provider-level latency calculated from saved prompt runs.',
      child: latencies.isEmpty
          ? AppStateView.empty(
              title: 'No Latency Data Yet',
              message:
                  'Legacy history items do not include response times. New prompt runs will populate this section automatically.',
              contained: false,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${summary.averageResponseTimeMs.toStringAsFixed(0)} ms overall average',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final metric in latencies)
                      _LatencyChip(metric: metric),
                  ],
                ),
              ],
            ),
    );
  }
}

class _LatencyChip extends StatelessWidget {
  const _LatencyChip({required this.metric});

  final ProviderLatencyMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${metric.provider}: ${metric.averageLatencyMs.toStringAsFixed(0)} ms',
          ),
        ],
      ),
    );
  }
}

double _maxTokenValue(List<ProviderTokenMetric> metrics) {
  if (metrics.isEmpty) {
    return 1;
  }

  final rawMax = metrics
      .map((metric) => metric.totalTokens.toDouble())
      .reduce(math.max);
  return rawMax <= 0 ? 1 : rawMax * 1.2;
}

double _maxPromptCount(List<DailyPromptMetric> metrics) {
  if (metrics.isEmpty) {
    return 1;
  }

  final rawMax = metrics
      .map((metric) => metric.promptCount.toDouble())
      .reduce(math.max);
  return rawMax <= 0 ? 1 : rawMax + 1;
}

double _bottomTitleInterval(int length) {
  if (length <= 7) {
    return 1;
  }
  if (length <= 14) {
    return 2;
  }
  return 3;
}

String _compactProvider(String value) {
  if (value.length <= 10) {
    return value;
  }

  final words = value.split(' ');
  if (words.length > 1) {
    return words.map((word) => word[0]).join().toUpperCase();
  }

  return value.substring(0, 10);
}

String _formatDay(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$month/$day';
}
