import 'package:flutter/material.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/feature_placeholder.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShellScaffold(
      title: 'History',
      currentRoute: AppRoutes.history,
      child: FeaturePlaceholder(
        title: 'History Workspace',
        description:
            'Use this feature to browse saved prompt runs, filter them, and '
            'support offline access to previous refinements.',
        highlights: [
          'Keep persistence details in the data layer.',
          'Use domain contracts for search, filter, and export flows.',
          'Let presentation providers drive selection and loading state.',
        ],
      ),
    );
  }
}
