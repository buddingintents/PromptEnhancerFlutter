import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/core/constants/llm_provider_models.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_language.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_theme_preference.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/provider_api_key.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_controller.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_providers.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_state.dart';
import 'package:prompt_enhancer/shared/widgets/app_button.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/app_state_view.dart';
import 'package:prompt_enhancer/shared/widgets/app_text_field.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);
    final configuredKeys = state.providerApiKeys
        .where((entry) => entry.isConfigured)
        .length;

    return AppShellScaffold(
      title: 'Settings',
      currentRoute: AppRoutes.settings,
      child: RefreshIndicator(
        onRefresh: controller.loadSettings,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1040;
            final useGrid = constraints.maxWidth >= 1180;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppCard(
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
                        'Settings Workspace',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Manage provider keys securely, choose the app theme, select provider-specific models, and keep language preferences aligned with how you work.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (state.error != null) ...[
                  AppStateView.error(
                    title: 'Settings Need Attention',
                    message: state.error!,
                    actionLabel: 'Retry',
                    onAction: controller.loadSettings,
                  ),
                  const SizedBox(height: 20),
                ],
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _PreferencesCard(
                          state: state,
                          controller: controller,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: _SecurityOverviewCard(
                          configuredKeys: configuredKeys,
                        ),
                      ),
                    ],
                  )
                else ...[
                  _SecurityOverviewCard(configuredKeys: configuredKeys),
                  const SizedBox(height: 20),
                  _PreferencesCard(state: state, controller: controller),
                ],
                const SizedBox(height: 24),
                AppCard(
                  title: 'Provider API Keys and Models',
                  subtitle:
                      'Each provider has its own secure API key and model selection. Keys are stored with flutter_secure_storage, and copy still uses the mock biometric check.',
                  trailing: Chip(label: Text('$configuredKeys configured')),
                ),
                const SizedBox(height: 16),
                if (state.loading)
                  AppStateView.loading(
                    title: 'Loading Provider Settings',
                    message:
                        'Reading secure storage and preparing provider configuration.',
                  )
                else ...[
                  if (configuredKeys == 0) ...[
                    AppStateView.empty(
                      title: 'No Provider Keys Yet',
                      message:
                          'Use any provider card below to choose a model, paste an API key, and save the provider for prompt refinement.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (useGrid)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: LLMProviderType.values.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            mainAxisExtent: 460,
                          ),
                      itemBuilder: (context, index) {
                        final provider = LLMProviderType.values[index];
                        return _buildProviderCard(state, provider);
                      },
                    )
                  else
                    Column(
                      children: [
                        for (final provider in LLMProviderType.values) ...[
                          _buildProviderCard(state, provider),
                          if (provider != LLMProviderType.values.last)
                            const SizedBox(height: 16),
                        ],
                      ],
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProviderCard(SettingsState state, LLMProviderType provider) {
    return _ProviderApiKeyCard(
      key: ValueKey(provider.key),
      entry: state.apiKeyFor(provider),
      selectedModel: state.resolvedModelFor(provider),
      isPreferredProvider: state.preferredProvider == provider,
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.state, required this.controller});

  final SettingsState state;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final preferredProvider = state.preferredProvider;
    final availableModels = LlmProviderModels.supportedModelsFor(
      preferredProvider,
    );
    final selectedModel = state.resolvedModelFor(preferredProvider);

    return AppCard(
      title: 'App Preferences',
      subtitle:
          'Choose how Prompt Enhancer looks and which provider and model are active by default.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<AppThemePreference>(
            segments: [
              for (final preference in AppThemePreference.values)
                ButtonSegment<AppThemePreference>(
                  value: preference,
                  label: Text(preference.label),
                ),
            ],
            selected: {state.themePreference},
            onSelectionChanged: (selection) {
              controller.updateThemePreference(selection.first);
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<AppLanguage>(
            initialValue: state.language,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Language'),
            items: AppLanguage.values
                .map(
                  (language) => DropdownMenuItem<AppLanguage>(
                    value: language,
                    child: Text(language.label),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                controller.updateLanguage(value);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<LLMProviderType>(
            initialValue: state.preferredProvider,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Default Provider'),
            items: LLMProviderType.values
                .map(
                  (provider) => DropdownMenuItem<LLMProviderType>(
                    value: provider,
                    child: Text(provider.displayName),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                controller.updatePreferredProvider(value);
              }
            },
          ),
          const SizedBox(height: 16),
          _ModelDropdown(
            label: 'Default Model',
            availableModels: availableModels,
            selectedModel: selectedModel,
            helperText:
                'This model is used when ${preferredProvider.displayName} is your active provider.',
            onChanged: (value) async {
              if (value == null) {
                return;
              }

              final messenger = ScaffoldMessenger.of(context);
              final message = await controller.updateProviderModel(
                preferredProvider,
                value,
              );

              if (!context.mounted) {
                return;
              }

              messenger.showSnackBar(SnackBar(content: Text(message)));
            },
          ),
        ],
      ),
    );
  }
}

class _SecurityOverviewCard extends StatelessWidget {
  const _SecurityOverviewCard({required this.configuredKeys});

  final int configuredKeys;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      title: 'Security Overview',
      subtitle:
          'A quick status view for secure storage and provider readiness.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.security_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$configuredKeys provider ${configuredKeys == 1 ? 'key is' : 'keys are'} stored securely.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Copy actions currently pass through a mock biometric guard so we can drop in real device authentication without refactoring the UI layer.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ProviderApiKeyCard extends ConsumerStatefulWidget {
  const _ProviderApiKeyCard({
    super.key,
    required this.entry,
    required this.selectedModel,
    required this.isPreferredProvider,
  });

  final ProviderApiKey entry;
  final String selectedModel;
  final bool isPreferredProvider;

  @override
  ConsumerState<_ProviderApiKeyCard> createState() =>
      _ProviderApiKeyCardState();
}

class _ProviderApiKeyCardState extends ConsumerState<_ProviderApiKeyCard> {
  late final TextEditingController _textController;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.entry.value);
    _textController.addListener(_handleDraftChanged);
  }

  @override
  void didUpdateWidget(covariant _ProviderApiKeyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.value != widget.entry.value) {
      _syncDraft(widget.entry.value);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_handleDraftChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);
    final draftValue = _textController.text.trim();
    final storedValue = widget.entry.value.trim();
    final canSave = draftValue.isNotEmpty && draftValue != storedValue;
    final hasUnsavedChanges = draftValue != storedValue;
    final availableModels = LlmProviderModels.supportedModelsFor(
      widget.entry.provider,
    );
    final selectedModel = availableModels.contains(widget.selectedModel)
        ? widget.selectedModel
        : availableModels.first;

    return AppCard(
      title: widget.entry.provider.displayName,
      subtitle: widget.entry.isConfigured
          ? widget.entry.maskedValue
          : 'No API key stored yet.',
      trailing: widget.isPreferredProvider
          ? Chip(
              avatar: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Default'),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.entry.isConfigured
                ? 'This provider is ready for use in the prompt workspace. Update the model or rotate the key below whenever needed.'
                : 'Choose a model and paste an API key below to enable this provider for prompt refinement.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _ModelDropdown(
            label: 'Model',
            availableModels: availableModels,
            selectedModel: selectedModel,
            onChanged: (value) async {
              if (value == null) {
                return;
              }

              final messenger = ScaffoldMessenger.of(context);
              final message = await controller.updateProviderModel(
                widget.entry.provider,
                value,
              );

              if (!context.mounted) {
                return;
              }

              messenger.showSnackBar(SnackBar(content: Text(message)));
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _textController,
            label: '${widget.entry.provider.displayName} API Key',
            hintText: widget.entry.isConfigured
                ? 'Update the stored key'
                : 'Paste your API key here',
            obscureText: _obscureText,
            keyboardType: TextInputType.visiblePassword,
            suffixIcon: SizedBox(
              width: hasUnsavedChanges ? 96 : 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasUnsavedChanges)
                    IconButton(
                      tooltip: 'Reset',
                      onPressed: () => _syncDraft(widget.entry.value),
                      icon: const Icon(Icons.restart_alt_rounded),
                    ),
                  IconButton(
                    tooltip: _obscureText ? 'Show key' : 'Hide key',
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.entry.isConfigured
                ? 'Only the masked value is shown in the card header. The full value stays inside secure storage until you edit or copy it.'
                : 'The key will be stored securely after you save it.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: widget.entry.isConfigured ? 'Save Changes' : 'Save Key',
                icon: widget.entry.isConfigured
                    ? Icons.save_outlined
                    : Icons.add,
                variant: AppButtonVariant.tonal,
                onPressed: canSave ? _saveApiKey : null,
              ),
              AppButton(
                label: 'Copy',
                icon: Icons.copy_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: widget.entry.isConfigured
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final message = await controller.copyApiKey(
                          widget.entry.provider,
                        );
                        if (!context.mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    : null,
              ),
              AppButton(
                label: 'Delete',
                icon: Icons.delete_outline,
                variant: AppButtonVariant.text,
                isDestructive: true,
                onPressed: widget.entry.isConfigured ? _confirmDelete : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveApiKey() async {
    final messenger = ScaffoldMessenger.of(context);
    final message = await ref
        .read(settingsControllerProvider.notifier)
        .saveApiKey(
          provider: widget.entry.provider,
          value: _textController.text,
        );

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete API Key'),
          content: Text(
            'Remove the stored API key for ${widget.entry.provider.displayName}?',
          ),
          actions: [
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            AppButton(
              label: 'Delete',
              isDestructive: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final message = await ref
        .read(settingsControllerProvider.notifier)
        .deleteApiKey(widget.entry.provider);

    if (!mounted) {
      return;
    }

    _syncDraft('');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleDraftChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncDraft(String value) {
    _textController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown({
    required this.label,
    required this.availableModels,
    required this.selectedModel,
    required this.onChanged,
    this.helperText,
  });

  final String label;
  final List<String> availableModels;
  final String selectedModel;
  final ValueChanged<String?> onChanged;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: availableModels.contains(selectedModel)
          ? selectedModel
          : availableModels.first,
      isExpanded: true,
      menuMaxHeight: 320,
      decoration: InputDecoration(labelText: label, helperText: helperText),
      selectedItemBuilder: (context) => availableModels
          .map(
            (model) => Align(
              alignment: Alignment.centerLeft,
              child: Text(model, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      items: availableModels
          .map(
            (model) => DropdownMenuItem<String>(
              value: model,
              child: Text(model, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
