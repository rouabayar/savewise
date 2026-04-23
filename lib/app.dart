import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'views/splash/splash_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/goal_detail/goal_detail_screen.dart';
import 'views/add_goal/add_goal_screen.dart';
import 'views/add_contribution/add_contribution_screen.dart';
import 'views/archive/archive_screen.dart';
import 'views/stats/stats_screen.dart';

class SaveWiseApp extends StatelessWidget {
  const SaveWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SaveWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/stats',     builder: (_, __) => const StatsScreen()),
        GoRoute(path: '/archive',   builder: (_, __) => const ArchiveScreen()),
      ],
    ),
    GoRoute(
      path: '/goal/:id',
      builder: (_, state) => GoalDetailScreen(goalId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/goal/new',    builder: (_, __) => const AddGoalScreen()),
    GoRoute(
      path: '/contribution/new/:goalId',
      builder: (_, state) =>
          AddContributionScreen(goalId: state.pathParameters['goalId']!),
    ),
  ],
);

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final _tabs = ['/dashboard', '/stats', '/archive'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          context.go(_tabs[i]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.archive_outlined),
              selectedIcon: Icon(Icons.archive), label: 'Archives'),
        ],
      ),
    );
  }
}
