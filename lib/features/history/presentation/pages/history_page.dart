import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_enhancer/core/constants/admob_constants.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_controller.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_filters.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_providers.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_state.dart';
import 'package:prompt_enhancer/features/prompt/presentation/providers/prompt_providers.dart';
import 'package:prompt_enhancer/shared/widgets/app_banner_ad_slot.dart';
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
    final hasActiveFilters =
        state.selectedTopic != null ||
        state.selectedProvider != null ||
        state.selectedDateFilter != HistoryDateFilter.all;

    return AppShellScaffold(
      title: 'History',
      currentRoute: AppRoutes.history,
      child: RefreshIndicator(
        onRefresh: controller.loadHistory,
        child: ListView(
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
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Review previous refinements, spot repeat patterns quickly, and jump back into any prompt when you want another iteration.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _HistoryHighlight(
                        label: 'Visible',
                        value: state.visibleCount.toString(),
                      ),
                      _HistoryHighlight(
                        label: 'Topics',
                        value: state.topicCount.toString(),
                      ),
                      _HistoryHighlight(
                        label: 'Providers',
                        value: state.providerCount.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              title: 'Find What You Need',
              subtitle: 'Filter by topic, provider, or time window.',
              trailing: hasActiveFilters
                  ? AppButton(
                      label: 'Clear',
                      icon: Icons.filter_alt_off_outlined,
                      variant: AppButtonVariant.text,
                      onPressed: () {
                        controller.setTopicFilter(null);
                        controller.setProviderFilter(null);
                        controller.setDateFilter(HistoryDateFilter.all);
                      },
                    )
                  : null,
              child: _HistoryFiltersCard(state: state, controller: controller),
            ),
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
            const SizedBox(height: 24),
            AppBannerAdSlot(
              adUnitId: AdMobConstants.bannerUnitIdFor(AppRoutes.history),
            ),
          ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth < 760
            ? constraints.maxWidth
            : (constraints.maxWidth - 32) / 3;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: fieldWidth,
              child: _HistoryFilterDropdown<String?>(
                label: 'Topic',
                value: state.selectedTopic,
                options: [
                  const _HistoryFilterOption<String?>(
                    value: null,
                    label: 'All topics',
                  ),
                  ...state.topics.map(
                    (topic) => _HistoryFilterOption<String?>(
                      value: topic,
                      label: topic,
                    ),
                  ),
                ],
                onChanged: controller.setTopicFilter,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: _HistoryFilterDropdown<String?>(
                label: 'Provider',
                value: state.selectedProvider,
                options: [
                  const _HistoryFilterOption<String?>(
                    value: null,
                    label: 'All providers',
                  ),
                  ...state.providers.map(
                    (provider) => _HistoryFilterOption<String?>(
                      value: provider,
                      label: provider,
                    ),
                  ),
                ],
                onChanged: controller.setProviderFilter,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: _HistoryFilterDropdown<HistoryDateFilter>(
                label: 'Time',
                value: state.selectedDateFilter,
                options: HistoryDateFilter.values
                    .map(
                      (filter) => _HistoryFilterOption<HistoryDateFilter>(
                        value: filter,
                        label: filter.label,
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
        );
      },
    );
  }
}

class _HistoryFilterDropdown<T> extends StatelessWidget {
  const _HistoryFilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<_HistoryFilterOption<T>> options;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: options
          .map(
            (option) => DropdownMenuItem<T>(
              value: option.value,
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      selectedItemBuilder: (context) {
        return options
            .map(
              (option) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false);
      },
      onChanged: onChanged,
    );
  }
}

class _HistoryFilterOption<T> {
  const _HistoryFilterOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _HistoryHighlight extends StatelessWidget {
  const _HistoryHighlight({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '0' : value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
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
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Icon(
                  Icons.history_toggle_off_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.topic, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetaPill(
                          icon: Icons.smart_toy_outlined,
                          label: item.provider,
                        ),
                        _MetaPill(
                          icon: Icons.schedule_outlined,
                          label: _formatTimestamp(item.timestamp),
                        ),
                        _MetaPill(
                          icon: Icons.tune_outlined,
                          label: '${item.tokens} tokens',
                        ),
                        if (item.latencyMs > 0)
                          _MetaPill(
                            icon: Icons.timer_outlined,
                            label: '${item.latencyMs} ms',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumns = constraints.maxWidth >= 860;

              if (!useColumns) {
                return Column(
                  children: [
                    _PromptPanel(label: 'Original Prompt', text: item.prompt),
                    const SizedBox(height: 14),
                    _PromptPanel(
                      label: 'Refined Prompt',
                      text: item.refinedPrompt,
                      emphasize: true,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PromptPanel(
                      label: 'Original Prompt',
                      text: item.prompt,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _PromptPanel(
                      label: 'Refined Prompt',
                      text: item.refinedPrompt,
                      emphasize: true,
                    ),
                  ),
                ],
              );
            },
          ),
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
                  context.push(AppRoutes.home);
                },
              ),
              AppButton(
                label: 'Copy Refined',
                icon: Icons.copy_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.refinedPrompt));
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
      ),
    );
  }
}

class _PromptPanel extends StatelessWidget {
  const _PromptPanel({
    required this.label,
    required this.text,
    this.emphasize = false,
  });

  final String label;
  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelColor = emphasize
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.42)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.68);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            _snippet(text),
            style: theme.textTheme.bodyMedium,
            maxLines: 7,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

String _snippet(String text) {
  final normalized = text.trim();
  if (normalized.length <= 280) {
    return normalized;
  }

  return '${normalized.substring(0, 280)}...';
}

String _formatTimestamp(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = value.day.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '$day ${months[value.month - 1]} ${value.year}, $hour:$minute $period';
}
