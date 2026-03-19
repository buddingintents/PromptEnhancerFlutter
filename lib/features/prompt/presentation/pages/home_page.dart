import 'package:flutter/material.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/feature_placeholder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShellScaffold(
      title: 'Home',
      currentRoute: AppRoutes.home,
      child: FeaturePlaceholder(
        title: 'Prompt Workspace',
        description:
            'Capture raw prompts, run provider-specific refinement flows, '
            'and surface structured results from the main workspace.',
        highlights: [
          'Keep orchestration inside domain use cases and repositories.',
          'Expose UI state with presentation providers only.',
          'Treat widgets as renderers, not owners of business rules.',
        ],
      ),
    );
  }
}
