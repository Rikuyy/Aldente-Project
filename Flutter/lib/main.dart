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

import '../login_system/splash.dart';
import '../login_system/sign_in.dart';
import '../login_system/sign_up.dart';
import '../login_system/forgot_password.dart';

void main() {
  runApp(const CookCashApp());
}
final _router = GoRouter(
  initialLocation: '/splash', // Mulai dari Splash Screen untuk cek login
  routes: [
    GoRoute(path: '/splash', builder: (ctx, state) => const SplashScreen()),
    GoRoute(path: '/sign_in', builder: (ctx, state) => const SignInScreen()),
    GoRoute(path: '/sign_up', builder: (ctx, state) => const SignUpScreen()),
    GoRoute(
        path: '/forgot_password',
        builder: (ctx, state) =>
            const ForgotPasswordScreen()), // Tambahkan rute ini

    GoRoute(path: '/', builder: (ctx, state) => const GuestModePage()),
    GoRoute(
        path: '/onboarding', builder: (ctx, state) => const OnboardingPage()),
    GoRoute(
        path: '/notifications',
        builder: (ctx, state) => const NotificationsPage()),
    GoRoute(path: '/todo', builder: (ctx, state) => const TodoPage()),

    ShellRoute(
      builder: (ctx, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/app/home', builder: (ctx, state) => const HomePage()),
        GoRoute(
            path: '/app/consultation',
            builder: (ctx, state) => const ConsultationPage()),
        GoRoute(
            path: '/app/finance', builder: (ctx, state) => const FinancePage()),
        GoRoute(
            path: '/app/inventory',
            builder: (ctx, state) => const InventoryPage()),
        GoRoute(
            path: '/app/profile', builder: (ctx, state) => const ProfilePage()),
        GoRoute(path: '/app/todo', builder: (ctx, state) => const TodoPage()),
      ],
    ),
  ],
);

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);



class CookCashApp extends StatelessWidget {
  const CookCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: 'CookCash',
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
