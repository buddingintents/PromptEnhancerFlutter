import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/features/trending/domain/entities/trending_topic.dart';
import 'package:prompt_enhancer/features/trending/presentation/providers/trending_providers.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/app_state_view.dart';

class TrendingPage extends ConsumerWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trendingControllerProvider);
    final controller = ref.read(trendingControllerProvider.notifier);
    final theme = Theme.of(context);

    return AppShellScaffold(
      title: 'Trending',
      currentRoute: AppRoutes.trending,
      child: RefreshIndicator(
        onRefresh: controller.loadTrendingTopics,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 1200
                ? 3
                : constraints.maxWidth >= 760
                ? 2
                : 1;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppCard(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondaryContainer,
                      theme.colorScheme.tertiaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trending Topics',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'These topic clusters come from your local history over the last 7 days. Tap a card to copy the most recent prompt behind that trend.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _FirebaseSyncPlaceholder(),
                const SizedBox(height: 20),
                if (state.loading && state.topics.isEmpty)
                  AppStateView.loading(
                    title: 'Analyzing Local Trends',
                    message:
                        'Looking through recent history to surface your most-used topics.',
                  )
                else if (state.error != null)
                  AppStateView.error(
                    title: 'Trending Unavailable',
                    message: state.error!,
                    actionLabel: 'Retry',
                    onAction: controller.loadTrendingTopics,
                  )
                else if (state.topics.isEmpty)
                  AppStateView.empty(
                    title: 'No Trends Yet',
                    message:
                        'Refine a few prompts first and this view will start surfacing the themes you use most.',
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.topics.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.18,
                    ),
                    itemBuilder: (context, index) {
                      final topic = state.topics[index];
                      return _TrendingTopicCard(topic: topic);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrendingTopicCard extends StatelessWidget {
  const _TrendingTopicCard({required this.topic});

  final TrendingTopic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: () {
        Clipboard.setData(ClipboardData(text: topic.samplePrompt));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied a recent ${topic.topic} prompt.')),
        );
      },
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.surface,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: topic.topic,
      subtitle: 'Last used ${_formatTimestamp(topic.lastUsedAt)}',
      trailing: Chip(
        avatar: const Icon(Icons.local_fire_department_outlined, size: 18),
        label: Text('${topic.usageCount} uses'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _snippet(topic.samplePrompt),
            style: theme.textTheme.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.copy_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tap to copy recent prompt',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FirebaseSyncPlaceholder extends StatelessWidget {
  const _FirebaseSyncPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      title: 'Firebase Sync Placeholder',
      subtitle:
          'Trending is currently computed locally from Hive-backed history. A remote sync adapter can plug in here later without changing the UI contract.',
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.cloud_sync_outlined,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

String _snippet(String text) {
  final normalized = text.trim();
  if (normalized.length <= 140) {
    return normalized;
  }

  return '${normalized.substring(0, 140)}...';
}

String _formatTimestamp(DateTime value) {
  final twoDigitMonth = value.month.toString().padLeft(2, '0');
  final twoDigitDay = value.day.toString().padLeft(2, '0');
  return '${value.year}-$twoDigitMonth-$twoDigitDay';
}
