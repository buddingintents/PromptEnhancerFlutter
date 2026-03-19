import 'package:flutter/material.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/feature_placeholder.dart';

class MetricsPage extends StatelessWidget {
  const MetricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShellScaffold(
      title: 'Metrics',
      currentRoute: AppRoutes.metrics,
      child: FeaturePlaceholder(
        title: 'Metrics Workspace',
        description:
            'Use this feature to calculate usage insights, chart performance, '
            'and compare providers over time.',
        highlights: [
          'Map raw provider responses in the data layer.',
          'Keep aggregation and reporting rules in domain use cases.',
          'Let presentation providers prepare chart-ready view state.',
        ],
      ),
    );
  }
}
