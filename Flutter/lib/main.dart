import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

// IMPORT Sistem Autentikasi
import 'login_system/splash.dart';
import 'login_system/sign_in.dart';
import 'login_system/sign_up.dart';
import 'login_system/forgot_password.dart';
import 'login_system/otp_ver.dart';
import 'login_system/reset_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const CookCasePlusApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen (halaman awal aplikasi)
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Guest Mode (halaman utama sebelum login)
    GoRoute(
      path: '/',
      builder: (context, state) => const GuestModePage(),
    ),

    // Autentikasi
    GoRoute(
      path: '/sign_in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign_up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final email = state.extra as String?;
        return OtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/reset_password',
      builder: (context, state) {
        final email = state.extra as String?;
        return ResetPasswordScreen(email: email);
      },
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    // Notifications
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),

    // ShellRoute untuk Bottom Navigation Bar (setelah login)
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/app/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/app/consultation',
          builder: (context, state) => const ConsultationPage(),
        ),
        GoRoute(
          path: '/app/finance',
          builder: (context, state) => const FinancePage(),
        ),
        GoRoute(
          path: '/app/inventory',
          builder: (context, state) => const InventoryPage(),
        ),
        GoRoute(
          path: '/app/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    // Redirect /app ke /app/home secara otomatis
    if (state.matchedLocation == '/app') return '/app/home';
    return null;
  },
);

class CookCasePlusApp extends StatelessWidget {
  const CookCasePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CookCase+',
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
