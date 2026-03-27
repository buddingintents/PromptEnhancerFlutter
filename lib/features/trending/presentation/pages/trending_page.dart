import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/constants/admob_constants.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/trending/domain/entities/trending_topic.dart';
import 'package:prompt_enhancer/features/trending/presentation/providers/trending_providers.dart';
import 'package:prompt_enhancer/shared/widgets/app_banner_ad_slot.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/app_state_view.dart';

class TrendingPage extends ConsumerWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingTopicsAsync = ref.watch(worldTrendingTopicsProvider);

    Future<void> refresh() async {
      ref.invalidate(worldTrendingTopicsProvider);
      await ref.read(worldTrendingTopicsProvider.future);
    }

    return AppShellScaffold(
      title: 'Trending',
      currentRoute: AppRoutes.trending,
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const _TrendingIntroCard(),
            const SizedBox(height: 20),
            trendingTopicsAsync.when(
              loading: () => AppStateView.loading(
                title: 'Loading Trends',
                message:
                    'Collecting the most active prompt topics from synced history.',
              ),
              error: (error, stackTrace) => AppStateView.error(
                title: 'Trending Unavailable',
                message: _mapErrorMessage(error),
                actionLabel: 'Retry',
                onAction: refresh,
              ),
              data: (topics) {
                if (topics.isEmpty) {
                  return AppStateView.empty(
                    title: 'No Trends Yet',
                    message:
                        'Once synced history builds up, the most active topics will appear here.',
                  );
                }

                return _SphereWordCloud(topics: topics);
              },
            ),
            const SizedBox(height: 24),
            AppBannerAdSlot(
              adUnitId: AdMobConstants.bannerUnitIdFor(AppRoutes.trending),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingIntroCard extends StatelessWidget {
  const _TrendingIntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primaryContainer,
          theme.colorScheme.tertiaryContainer,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Worldwide Prompt Trends',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This rotating sphere highlights the three most used prompt categories from the last 7 days. Larger words represent higher usage volume across the app.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _TrendingInfoChip(label: 'Synced worldwide activity'),
              _TrendingInfoChip(label: 'Top 3 most used categories'),
              _TrendingInfoChip(label: 'Larger words = more usage'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendingInfoChip extends StatelessWidget {
  const _TrendingInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _SphereWordCloud extends StatefulWidget {
  const _SphereWordCloud({required this.topics});

  final List<TrendingTopic> topics;

  @override
  State<_SphereWordCloud> createState() => _SphereWordCloudState();
}

class _SphereWordCloudState extends State<_SphereWordCloud>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primaryContainer.withValues(alpha: 0.78),
          theme.colorScheme.secondaryContainer.withValues(alpha: 0.72),
          theme.colorScheme.tertiaryContainer.withValues(alpha: 0.74),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportHeight = MediaQuery.sizeOf(context).height;
          final sphereSize = math.min(
            constraints.maxWidth,
            math.max(380.0, viewportHeight * 0.6),
          );
          final radius = sphereSize * 0.28;
          final maxUsage = widget.topics
              .map((topic) => topic.usageCount)
              .reduce(math.max)
              .toDouble();

          return SizedBox(
            height: sphereSize,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final projections = _buildProjections(
                  topics: widget.topics,
                  radius: radius,
                  maxUsage: maxUsage,
                  rotation: _controller.value,
                );

                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: sphereSize * 0.82,
                        height: sphereSize * 0.82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.62),
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                              theme.colorScheme.primary.withValues(alpha: 0.02),
                            ],
                            stops: const [0.0, 0.58, 1.0],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.34),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 32,
                              spreadRadius: 2,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (final projection in projections)
                      Align(
                        alignment: Alignment.center,
                        child: Transform.translate(
                          offset: Offset(projection.x, projection.y),
                          child: Opacity(
                            opacity: projection.opacity,
                            child: Transform.scale(
                              scale: projection.scale,
                              child: _SphereWord(
                                topic: projection.topic,
                                fontSize: projection.fontSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

List<_ProjectedTopic> _buildProjections({
  required List<TrendingTopic> topics,
  required double radius,
  required double maxUsage,
  required double rotation,
}) {
  final projections = <_ProjectedTopic>[];
  final spinY = rotation * math.pi * 2;
  final spinX = math.sin(rotation * math.pi * 2) * 0.38;

  for (var index = 0; index < topics.length; index++) {
    final point = _fibonacciPoint(index, topics.length);
    final rotatedPoint = _rotatePoint(point, spinY: spinY, spinX: spinX);
    final depth = ((rotatedPoint.z + 1) / 2).clamp(0.0, 1.0);
    final prominence = maxUsage <= 0
        ? 0.5
        : (topics[index].usageCount / maxUsage).clamp(0.0, 1.0);

    projections.add(
      _ProjectedTopic(
        topic: topics[index],
        x: rotatedPoint.x * radius,
        y: rotatedPoint.y * radius * 0.72,
        z: rotatedPoint.z,
        scale: 0.78 + (depth * 0.72),
        opacity: 0.38 + (depth * 0.62),
        fontSize: 18 + (18 * prominence),
      ),
    );
  }

  projections.sort((left, right) => left.z.compareTo(right.z));
  return projections;
}

_Point3D _fibonacciPoint(int index, int total) {
  final offset = 2.0 / total;
  final increment = math.pi * (3 - math.sqrt(5));
  final y = ((index * offset) - 1) + (offset / 2);
  final radius = math.sqrt(1 - (y * y));
  final phi = index * increment;
  final x = math.cos(phi) * radius;
  final z = math.sin(phi) * radius;
  return _Point3D(x: x, y: y, z: z);
}

_Point3D _rotatePoint(
  _Point3D point, {
  required double spinY,
  required double spinX,
}) {
  final cosY = math.cos(spinY);
  final sinY = math.sin(spinY);
  final x1 = (point.x * cosY) + (point.z * sinY);
  final z1 = (-point.x * sinY) + (point.z * cosY);

  final cosX = math.cos(spinX);
  final sinX = math.sin(spinX);
  final y2 = (point.y * cosX) - (z1 * sinX);
  final z2 = (point.y * sinX) + (z1 * cosX);

  return _Point3D(x: x1, y: y2, z: z2);
}

class _SphereWord extends StatelessWidget {
  const _SphereWord({required this.topic, required this.fontSize});

  final TrendingTopic topic;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Text(
          topic.topic,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _ProjectedTopic {
  const _ProjectedTopic({
    required this.topic,
    required this.x,
    required this.y,
    required this.z,
    required this.scale,
    required this.opacity,
    required this.fontSize,
  });

  final TrendingTopic topic;
  final double x;
  final double y;
  final double z;
  final double scale;
  final double opacity;
  final double fontSize;
}

class _Point3D {
  const _Point3D({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;
}

String _mapErrorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }

  return 'Unable to load worldwide trends right now.';
}
