import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_enhancer/core/constants/admob_constants.dart';
import 'package:prompt_enhancer/core/constants/app_constants.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/features/prompt/presentation/providers/prompt_providers.dart';
import 'package:prompt_enhancer/shared/widgets/app_banner_ad_slot.dart';
import 'package:prompt_enhancer/shared/widgets/app_button.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/app_state_view.dart';
import 'package:prompt_enhancer/shared/widgets/app_text_field.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = ref.watch(
      promptControllerProvider.select((state) => state.input),
    );
    final providerView = ref.watch(
      activePromptProviderConfigProvider.select(
        (config) => (
          providerName: config.providerName,
          model: config.model,
          apiKeyConfigured: config.apiKey.trim().isNotEmpty,
        ),
      ),
    );
    final theme = Theme.of(context);

    if (_textController.text != input) {
      _textController.value = TextEditingValue(
        text: input,
        selection: TextSelection.collapsed(offset: input.length),
      );
    }

    return AppShellScaffold(
      title: 'Home',
      currentRoute: AppRoutes.home,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1080;

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
                      'Prompt Workspace',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Shape rough ideas into clearer prompts with guided setup, provider-aware execution, and result metadata designed for real use.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              if (!providerView.apiKeyConfigured) ...[
                const SizedBox(height: 20),
                const _FirstApiKeyGuidanceCard(),
              ],
              const SizedBox(height: 20),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _ComposerCard(textController: _textController),
                          const SizedBox(height: 20),
                          const _ProviderOverviewCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _RunInsightsCard(),
                          SizedBox(height: 20),
                          _OutputCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _ComposerCard(textController: _textController),
                const SizedBox(height: 20),
                const _ProviderOverviewCard(),
                const SizedBox(height: 20),
                const _RunInsightsCard(),
                const SizedBox(height: 20),
                const _OutputCard(),
              ],
              const SizedBox(height: 24),
              AppBannerAdSlot(
                adUnitId: AdMobConstants.bannerUnitIdFor(AppRoutes.home),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FirstApiKeyGuidanceCard extends StatelessWidget {
  const _FirstApiKeyGuidanceCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Add Your First API Key',
      subtitle:
          'You need one provider key before Prompt Enhancer can detect topics and refine prompts.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good starting points right now: Gemini and Hugging Face currently offer free developer access. OpenAI may allow limited first-use testing, while Claude and Perplexity generally need billing or credits. Availability can change by provider.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _GuideChip(label: 'Gemini: free tier available'),
              _GuideChip(label: 'Hugging Face: starter access available'),
              _GuideChip(label: 'OpenAI: usually billing required'),
              _GuideChip(label: 'Claude: credits or billing required'),
              _GuideChip(label: 'Perplexity: billing usually required'),
            ],
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Open Settings',
            icon: Icons.settings_outlined,
            variant: AppButtonVariant.tonal,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _GuideChip extends StatelessWidget {
  const _GuideChip({required this.label});

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
      child: Text(label, style: theme.textTheme.labelLarge),
    );
  }
}

class _ComposerCard extends ConsumerWidget {
  const _ComposerCard({required this.textController});

  final TextEditingController textController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final composerView = ref.watch(
      promptControllerProvider.select(
        (state) => (
          input: state.input,
          loading: state.loading,
          loadingMessage: state.loadingMessage,
          error: state.error,
          structuredOutputOnly: state.structuredOutputOnly,
        ),
      ),
    );
    final providerView = ref.watch(
      activePromptProviderConfigProvider.select(
        (config) => (
          providerName: config.providerName,
          apiKeyConfigured: config.apiKey.trim().isNotEmpty,
        ),
      ),
    );
    final controller = ref.read(promptControllerProvider.notifier);
    final canRefine =
        composerView.input.trim().isNotEmpty && providerView.apiKeyConfigured;
    final errorAction = _resolvePromptErrorAction(
      context,
      controller,
      composerView.error,
    );

    return AppCard(
      title: 'Compose Your Prompt',
      subtitle:
          'Describe the outcome, format, constraints, and any domain context you want the model to follow.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: textController,
            onChanged: controller.updateInput,
            label: 'Prompt Input',
            hintText:
                'Example: Rewrite this product brief into a concise, structured prompt for a marketing copywriter.',
            maxLength: AppConstants.maxPromptCharacters,
            minLines: 10,
            maxLines: 14,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              value: composerView.structuredOutputOnly,
              onChanged: (value) {
                controller.toggleStructuredOutputOnly(value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Structured output only'),
              subtitle: const Text(
                'Adds a JSON-only example to the refined prompt so downstream models return structured output.',
              ),
            ),
          ),
          if (!providerView.apiKeyConfigured) ...[
            const SizedBox(height: 16),
            AppStateView.empty(
              title: 'API Key Required',
              message:
                  'Add an API key in Settings before running topic detection or prompt refinement.',
              actionLabel: 'Open Settings',
              onAction: () => context.push(AppRoutes.settings),
              contained: false,
            ),
          ],
          if (composerView.loading) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
            const SizedBox(height: 10),
            Text(
              composerView.loadingMessage ?? 'Working on your prompt...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (composerView.error != null) ...[
            const SizedBox(height: 16),
            AppStateView.error(
              title: 'Refinement Blocked',
              message: composerView.error!,
              actionLabel: errorAction?.label,
              onAction: errorAction?.onAction,
              contained: false,
            ),
          ],
          const SizedBox(height: 20),
          AppButton(
            label: providerView.apiKeyConfigured
                ? (composerView.loading ? 'Refining Prompt' : 'Refine Prompt')
                : 'Add API Key First',
            icon: providerView.apiKeyConfigured
                ? Icons.auto_fix_high
                : Icons.settings_outlined,
            variant: providerView.apiKeyConfigured
                ? AppButtonVariant.filled
                : AppButtonVariant.tonal,
            onPressed: providerView.apiKeyConfigured
                ? (canRefine ? controller.refinePrompt : null)
                : () => context.push(AppRoutes.settings),
            loading: composerView.loading,
            expanded: true,
          ),
        ],
      ),
    );
  }
}

class _ProviderOverviewCard extends ConsumerWidget {
  const _ProviderOverviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerView = ref.watch(
      activePromptProviderConfigProvider.select(
        (config) => (
          providerName: config.providerName,
          model: config.model,
          apiKeyConfigured: config.apiKey.trim().isNotEmpty,
        ),
      ),
    );

    return AppCard(
      title: 'Active Provider',
      trailing: Chip(
        avatar: Icon(
          providerView.apiKeyConfigured
              ? Icons.verified_outlined
              : Icons.warning_amber_rounded,
          size: 18,
        ),
        label: Text(providerView.apiKeyConfigured ? 'Ready' : 'Needs Key'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ProviderPill(
                icon: Icons.cloud_outlined,
                label: providerView.providerName,
              ),
              _ProviderPill(
                icon: Icons.memory_outlined,
                label: providerView.model,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            providerView.apiKeyConfigured
                ? 'The selected provider is ready for the next prompt run.'
                : 'Finish the setup in Settings to start topic detection and refinement.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ProviderPill extends StatelessWidget {
  const _ProviderPill({required this.icon, required this.label});

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
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _RunInsightsCard extends ConsumerWidget {
  const _RunInsightsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(
      promptControllerProvider.select(
        (state) => (
          topic: state.topic,
          reasoningDepth: state.reasoningDepth,
          topicConfidence: state.topicConfidence,
          refinedOutput: state.refinedOutput,
          provider: state.provider,
          tokens: state.tokens,
          latencyMs: state.latencyMs,
          structuredOutputOnly: state.structuredOutputOnly,
        ),
      ),
    );
    final hasTopic = _hasContent(insights.topic);
    final hasOutput = _hasContent(insights.refinedOutput);

    return AppCard(
      title: 'Run Insights',
      subtitle:
          'Topic detection, confidence, and execution details appear here after each refinement.',
      child: hasTopic || hasOutput
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (hasTopic)
                      Chip(
                        avatar: const Icon(Icons.sell_outlined, size: 18),
                        label: Text(insights.topic!),
                      ),
                    if (insights.reasoningDepth != null)
                      Chip(
                        avatar: const Icon(
                          Icons.psychology_alt_outlined,
                          size: 18,
                        ),
                        label: Text(insights.reasoningDepth!),
                      ),
                    if (insights.topicConfidence != null)
                      Chip(
                        avatar: const Icon(Icons.verified_outlined, size: 18),
                        label: Text(
                          '${(insights.topicConfidence! * 100).toStringAsFixed(0)}% confidence',
                        ),
                      ),
                    if (insights.structuredOutputOnly)
                      const Chip(
                        avatar: Icon(Icons.data_object, size: 18),
                        label: Text('JSON-only mode'),
                      ),
                  ],
                ),
                if (hasOutput) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetadataPill(
                        icon: Icons.cloud_outlined,
                        label: 'Provider',
                        value: insights.provider ?? 'Unknown',
                      ),
                      _MetadataPill(
                        icon: Icons.tune_outlined,
                        label: 'Tokens',
                        value: '${insights.tokens ?? 0}',
                      ),
                      _MetadataPill(
                        icon: Icons.timer_outlined,
                        label: 'Latency',
                        value: '${insights.latencyMs ?? 0} ms',
                      ),
                    ],
                  ),
                ],
              ],
            )
          : AppStateView.empty(
              title: 'No Run Data Yet',
              message:
                  'Once you refine a prompt, this panel will show the detected topic and execution metadata.',
              contained: false,
            ),
    );
  }
}

class _OutputCard extends ConsumerWidget {
  const _OutputCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outputView = ref.watch(
      promptControllerProvider.select(
        (state) => (
          refinedOutput: state.refinedOutput,
          loading: state.loading,
          loadingMessage: state.loadingMessage,
          structuredOutputOnly: state.structuredOutputOnly,
        ),
      ),
    );
    final hasOutput = _hasContent(outputView.refinedOutput);

    return AppCard(
      title: 'Refined Output',
      subtitle: outputView.structuredOutputOnly
          ? 'This prompt now includes a JSON-only example for structured downstream responses.'
          : 'Review the enhanced prompt and copy it straight into your next workflow.',
      child: outputView.loading && !hasOutput
          ? AppStateView.loading(
              title: outputView.loadingMessage ?? 'Refining Prompt',
              message:
                  'Please wait while the app completes topic detection and prompt refinement.',
              contained: false,
            )
          : hasOutput
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectionArea(
                  child: SelectableText(
                    outputView.refinedOutput!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Copy Output',
                  icon: Icons.copy_outlined,
                  variant: AppButtonVariant.tonal,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: outputView.refinedOutput!),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refined prompt copied.')),
                    );
                  },
                ),
              ],
            )
          : AppStateView.empty(
              title: 'Nothing To Show Yet',
              message:
                  'The refined prompt will appear here after the topic detection and rewrite flow completes.',
              contained: false,
            ),
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text('$label: $value'),
        ],
      ),
    );
  }
}

({String label, VoidCallback onAction})? _resolvePromptErrorAction(
  BuildContext context,
  PromptController controller,
  String? error,
) {
  if (error == null || error.trim().isEmpty) {
    return null;
  }

  final normalized = error.toLowerCase();
  if (normalized.contains('api key') ||
      normalized.contains('authentication') ||
      normalized.contains('settings') ||
      normalized.contains('model')) {
    return (
      label: 'Open Settings',
      onAction: () => context.push(AppRoutes.settings),
    );
  }

  return (label: 'Retry', onAction: controller.refinePrompt);
}

bool _hasContent(String? value) {
  return value != null && value.trim().isNotEmpty;
}
