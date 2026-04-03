import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/scaffold_with_navbar.dart';
import 'features/tasks/screens/tasks_screen.dart';
import 'features/hydration/screens/hydration_screen.dart';
import 'features/mood/screens/mood_screen.dart';
import 'features/summary/screens/summary_screen.dart';

final _router = GoRouter(
  initialLocation: '/tasks',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavbar(child: child),
      routes: [
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/hydration',
          builder: (context, state) => const HydrationScreen(),
        ),
        GoRoute(
          path: '/mood',
          builder: (context, state) => const MoodScreen(),
        ),
        GoRoute(
          path: '/summary',
          builder: (context, state) => const SummaryScreen(),
        ),
      ],
    ),
  ],
);

class DayFlowApp extends StatelessWidget {
  const DayFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DayFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _router,
    );
  }
}
