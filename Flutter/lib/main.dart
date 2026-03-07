import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_system/sign_up.dart';
import 'login_system/forgot_password.dart';
import 'login_system/otp_ver.dart';
import 'login_system/sign_in.dart';
import 'login_system/welcome.dart';
import 'login_system/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool regComplete = prefs.getBool('registration_complete') ?? false;

  runApp(MainApp(
    initialRoute: regComplete ? '/splash' : '/signin', // or '/welcome'
  ));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cook Mate',
      initialRoute: initialRoute,
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome!')),
    );
  }
}
