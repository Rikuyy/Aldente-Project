import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'pages/guest_mode_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/main_layout.dart';
import 'pages/home_page.dart';
import 'pages/consultation_page.dart';
import 'pages/finance_page.dart';
import 'pages/inventory_page.dart';
import 'pages/profile_page.dart';
import 'pages/notifications_page.dart';
import 'pages/todo_page.dart';


void main() {
  runApp(const DarkModeCooking(child: CookCashApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, state) => const GuestModePage()),
    GoRoute(path: '/onboarding', builder: (ctx, state) => const OnboardingPage()),
    GoRoute(path: '/notifications', builder: (ctx, state) => const NotificationsPage()),
    GoRoute(path: '/todo', builder: (ctx, state) => const TodoPage()),
    ShellRoute(
      builder: (ctx, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/app/home', builder: (ctx, state) => const HomePage()),
        GoRoute(path: '/app/consultation', builder: (ctx, state) => const ConsultationPage()),
        GoRoute(path: '/app/finance', builder: (ctx, state) => const FinancePage()),
        GoRoute(path: '/app/inventory', builder: (ctx, state) => const InventoryPage()),
        GoRoute(path: '/app/profile', builder: (ctx, state) => const ProfilePage()),
        GoRoute(path: '/app/todo', builder: (ctx, state) => const TodoPage()),
      ],
    ),
  ],
redirect: (ctx, state) {
  if (state.matchedLocation == '/app') return '/app/home'; // dead code
  return null;

  },
);

class CookCashApp extends StatelessWidget {
  const CookCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = DarkModeCooking.of(context).themeMode;

    return MaterialApp.router(
      title: 'CookCash',
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme, 
      themeMode: mode,          
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class DarkModeCooking extends StatefulWidget {
  final Widget child; // Added child property to embed CookCashApp
  const DarkModeCooking({super.key, required this.child});

  static DarkModeCookingState of(BuildContext context) =>
    context.findAncestorStateOfType<DarkModeCookingState>()!;

  @override
  State<DarkModeCooking> createState() => DarkModeCookingState();
}

class DarkModeCookingState extends State<DarkModeCooking> {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
