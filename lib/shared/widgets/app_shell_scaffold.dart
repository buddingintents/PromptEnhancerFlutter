import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_enhancer/core/constants/app_constants.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
  });

  final String title;
  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [
                    for (final item in _navigationItems)
                      ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.label),
                        selected: item.route == currentRoute,
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
      body: SafeArea(child: child),
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
    label: 'Settings',
    route: AppRoutes.settings,
    icon: Icons.settings,
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
