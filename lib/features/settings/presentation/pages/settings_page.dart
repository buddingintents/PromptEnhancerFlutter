import 'package:flutter/material.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/feature_placeholder.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShellScaffold(
      title: 'Settings',
      currentRoute: AppRoutes.settings,
      child: FeaturePlaceholder(
        title: 'Settings Workspace',
        description:
            'Use this feature to manage providers, API keys, and user '
            'preferences without leaking infrastructure into the UI layer.',
        highlights: [
          'Secure storage adapters belong in the data layer.',
          'Use cases should coordinate validation and persistence rules.',
          'Presentation providers own form state and interaction flow.',
        ],
      ),
    );
  }
}
