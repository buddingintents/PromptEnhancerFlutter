import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_controller.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_filters.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_providers.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_state.dart';
import 'package:prompt_enhancer/features/prompt/presentation/providers/prompt_providers.dart';
import 'package:prompt_enhancer/shared/widgets/app_button.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/app_state_view.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);
    final theme = Theme.of(context);

    return AppShellScaffold(
      title: 'History',
      currentRoute: AppRoutes.history,
      child: RefreshIndicator(
        onRefresh: controller.loadHistory,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppCard(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.tertiaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prompt History',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Browse previous refinements, filter them quickly, and send any original prompt back into the workspace when you want to iterate.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: _HistoryFiltersCard(
                          state: state,
                          controller: controller,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: _HistorySummaryCard(state: state),
                      ),
                    ],
                  )
                else ...[
                  _HistorySummaryCard(state: state),
                  const SizedBox(height: 20),
                  _HistoryFiltersCard(state: state, controller: controller),
                ],
                const SizedBox(height: 20),
                if (state.loading && state.filteredItems.isEmpty)
                  AppStateView.loading(
                    title: 'Loading History',
                    message:
                        'Fetching saved prompt runs and preparing your filters.',
                  )
                else if (state.error != null)
                  AppStateView.error(
                    title: 'History Unavailable',
                    message: state.error!,
                    actionLabel: 'Retry',
                    onAction: controller.loadHistory,
                  )
                else if (state.filteredItems.isEmpty)
                  AppStateView.empty(
                    title: 'No Matching History',
                    message:
                        'Try a different filter combination or refine a few prompts to build history.',
                  )
                else
                  ...state.filteredItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HistoryItemCard(item: item),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryFiltersCard extends StatelessWidget {
  const _HistoryFiltersCard({required this.state, required this.controller});

  final HistoryState state;
  final HistoryController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Filters',
      subtitle: 'Focus on a topic, provider, or time window.',
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String?>(
              initialValue: state.selectedTopic,
              decoration: const InputDecoration(labelText: 'Topic'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All topics'),
                ),
                ...state.topics.map(
                  (topic) => DropdownMenuItem<String?>(
                    value: topic,
                    child: Text(topic),
                  ),
                ),
              ],
              onChanged: controller.setTopicFilter,
            ),
          ),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String?>(
              initialValue: state.selectedProvider,
              decoration: const InputDecoration(labelText: 'Provider'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All providers'),
                ),
                ...state.providers.map(
                  (provider) => DropdownMenuItem<String?>(
                    value: provider,
                    child: Text(provider),
                  ),
                ),
              ],
              onChanged: controller.setProviderFilter,
            ),
          ),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<HistoryDateFilter>(
              initialValue: state.selectedDateFilter,
              decoration: const InputDecoration(labelText: 'Date'),
              items: HistoryDateFilter.values
                  .map(
                    (filter) => DropdownMenuItem<HistoryDateFilter>(
                      value: filter,
                      child: Text(filter.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  controller.setDateFilter(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySummaryCard extends StatelessWidget {
  const _HistorySummaryCard({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Snapshot',
      subtitle: 'A quick view of the currently visible results.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _SummaryPill(
            label: 'Visible',
            value: '${state.filteredItems.length}',
          ),
          _SummaryPill(label: 'Topics', value: '${state.topics.length}'),
          _SummaryPill(label: 'Providers', value: '${state.providers.length}'),
        ],
      ),
    );
  }
}

class _HistoryItemCard extends ConsumerWidget {
  const _HistoryItemCard({required this.item});

  final HistoryEntry item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(historyControllerProvider.notifier);

    return AppCard(
      title: item.topic,
      subtitle: '${item.provider} | ${_formatTimestamp(item.timestamp)}',
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Chip(label: Text('${item.tokens} tokens')),
          if (item.latencyMs > 0) Chip(label: Text('${item.latencyMs} ms')),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useTwoColumns = constraints.maxWidth >= 820;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (useTwoColumns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PromptBlock(
                        title: 'Original Prompt',
                        text: item.prompt,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PromptBlock(
                        title: 'Refined Prompt',
                        text: item.refinedPrompt,
                      ),
                    ),
                  ],
                )
              else ...[
                _PromptBlock(title: 'Original Prompt', text: item.prompt),
                const SizedBox(height: 16),
                _PromptBlock(title: 'Refined Prompt', text: item.refinedPrompt),
              ],
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AppButton(
                    label: 'Rerun',
                    icon: Icons.replay_outlined,
                    variant: AppButtonVariant.tonal,
                    onPressed: () {
                      ref
                          .read(promptControllerProvider.notifier)
                          .loadDraft(item.prompt);
                      context.go(AppRoutes.home);
                    },
                  ),
                  AppButton(
                    label: 'Copy',
                    icon: Icons.copy_outlined,
                    variant: AppButtonVariant.outlined,
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: item.refinedPrompt),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Refined prompt copied.')),
                      );
                    },
                  ),
                  AppButton(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    variant: AppButtonVariant.text,
                    isDestructive: true,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final message = await controller.deleteItem(item);
                      messenger.showSnackBar(SnackBar(content: Text(message)));
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PromptBlock extends StatelessWidget {
  const _PromptBlock({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(_snippet(text), style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text('$label: $value'),
    );
  }
}

String _snippet(String text) {
  final normalized = text.trim();
  if (normalized.length <= 220) {
    return normalized;
  }

  return '${normalized.substring(0, 220)}...';
}

String _formatTimestamp(DateTime value) {
  final twoDigitMonth = value.month.toString().padLeft(2, '0');
  final twoDigitDay = value.day.toString().padLeft(2, '0');
  final twoDigitHour = value.hour.toString().padLeft(2, '0');
  final twoDigitMinute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$twoDigitMonth-$twoDigitDay $twoDigitHour:$twoDigitMinute';
}
