import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_enhancer/core/constants/app_constants.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/features/history/presentation/pages/history_page.dart';
import 'package:prompt_enhancer/features/metrics/presentation/pages/metrics_page.dart';
import 'package:prompt_enhancer/features/prompt/presentation/pages/home_page.dart';
import 'package:prompt_enhancer/features/settings/presentation/pages/settings_page.dart';
import 'package:prompt_enhancer/features/trending/presentation/pages/trending_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      if (state.matchedLocation == '/') {
        return AppRoutes.splash;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: AppRouteNames.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.trending,
        name: AppRouteNames.trending,
        builder: (context, state) => const TrendingPage(),
      ),
      GoRoute(
        path: AppRoutes.metrics,
        name: AppRouteNames.metrics,
        builder: (context, state) => const MetricsPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_fix_high,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(AppConstants.appName, style: theme.textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(
                'Refine rough ideas into structured prompts with a clean, '
                'feature-first Flutter architecture.',
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Enter App'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
