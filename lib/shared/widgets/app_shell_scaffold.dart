import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_enhancer/core/constants/app_constants.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final String currentRoute;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 960;
    final useExtendedRail = width >= 1280;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: useRail ? null : _NavigationDrawer(currentRoute: currentRoute),
      body: SafeArea(
        child: Row(
          children: [
            if (useRail)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                child: _NavigationRail(
                  currentRoute: currentRoute,
                  extended: useExtendedRail,
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.all(18),
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
                    Icon(
                      Icons.auto_fix_high,
                      size: 28,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Prompt refinement, history, analytics, and settings in one workspace.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    for (final item in _navigationItems)
                      ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.label),
                        selected: item.route == currentRoute,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          if (item.route != currentRoute) {
                            context.go(item.route);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({required this.currentRoute, required this.extended});

  final String currentRoute;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _navigationItems.indexWhere(
      (item) => item.route == currentRoute,
    );

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_fix_high),
                if (extended) ...[
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ],
            ),
          ),
          NavigationRail(
            extended: extended,
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onDestinationSelected: (index) {
              final destination = _navigationItems[index];
              if (destination.route != currentRoute) {
                context.go(destination.route);
              }
            },
            destinations: [
              for (final item in _navigationItems)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

const List<_NavigationItem> _navigationItems = [
  _NavigationItem(
    label: 'Home',
    route: AppRoutes.home,
    icon: Icons.auto_fix_high,
  ),
  _NavigationItem(
    label: 'History',
    route: AppRoutes.history,
    icon: Icons.history,
  ),
  _NavigationItem(
    label: 'Trending',
    route: AppRoutes.trending,
    icon: Icons.trending_up,
  ),
  _NavigationItem(
    label: 'Metrics',
    route: AppRoutes.metrics,
    icon: Icons.insights,
  ),
  _NavigationItem(
    label: 'Settings',
    route: AppRoutes.settings,
    icon: Icons.settings,
  ),
];

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}
