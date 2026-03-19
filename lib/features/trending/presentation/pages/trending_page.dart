import 'package:flutter/material.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/shared/widgets/app_shell_scaffold.dart';
import 'package:prompt_enhancer/shared/widgets/feature_placeholder.dart';

class TrendingPage extends StatelessWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShellScaffold(
      title: 'Trending',
      currentRoute: AppRoutes.trending,
      child: FeaturePlaceholder(
        title: 'Trending Workspace',
        description:
            'Use this feature to analyze local prompt activity and surface '
            'trending topics or reusable prompt patterns.',
        highlights: [
          'Keep analytics aggregation outside widgets.',
          'Define ranking rules through domain use cases.',
          'Use presentation providers for refresh and filter state.',
        ],
      ),
    );
  }
}
