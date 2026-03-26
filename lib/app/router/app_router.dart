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
import 'package:prompt_enhancer/shared/widgets/app_button.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';

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
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 920;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Expanded(flex: 6, child: _SplashHeroCard()),
                            SizedBox(width: 20),
                            Expanded(flex: 4, child: _SplashInfoCard()),
                          ],
                        )
                      : const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SplashHeroCard(),
                            SizedBox(height: 20),
                            _SplashInfoCard(),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SplashHeroCard extends StatelessWidget {
  const _SplashHeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primaryContainer,
          theme.colorScheme.secondaryContainer,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/branding/app_icon.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppConstants.appName,
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Turn rough ideas into clear, polished prompts you can use right away.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start with a quick draft, improve it in one tap, and keep your best results ready for later.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.88,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(label: Text('Improve prompts faster')),
              Chip(label: Text('Save what works')),
              Chip(label: Text('Keep your keys private')),
            ],
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Enter App',
            onPressed: () => context.go(AppRoutes.home),
            icon: Icons.arrow_forward_rounded,
            expanded: true,
          ),
        ],
      ),
    );
  }
}

class _SplashInfoCard extends StatelessWidget {
  const _SplashInfoCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'What You Can Do',
      subtitle:
          'Everything here is focused on helping you write better prompts with less effort.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _SplashBullet(
            icon: Icons.edit_note_rounded,
            title: 'Refine Any Draft',
            message:
                'Paste a rough idea, improve it instantly, and reuse the result whenever you need it.',
          ),
          SizedBox(height: 16),
          _SplashBullet(
            icon: Icons.insights_outlined,
            title: 'See What Works',
            message:
                'Review your history, spot popular topics, and track usage patterns from your saved activity.',
          ),
          SizedBox(height: 16),
          _SplashBullet(
            icon: Icons.security_outlined,
            title: 'Stay In Control',
            message:
                'Choose your preferred provider, manage models, and store API keys securely in one place.',
          ),
        ],
      ),
    );
  }
}

class _SplashBullet extends StatelessWidget {
  const _SplashBullet({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(message, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
