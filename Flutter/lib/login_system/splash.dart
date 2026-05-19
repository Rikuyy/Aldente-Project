import 'package:cook_cash/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_services.dart'; // Import service yang kamu buat tadi

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;
  final AuthService _authService = AuthService();

  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to CookCash, Time to cook!",
      "image": "https://i.postimg.cc/mhhVywp9/splash-1.png"
    },
    {
      "text": "We help people to find best recipe",
      "image": "https://i.postimg.cc/3x3ZzL8C/splash-2.png"
    },
    {
      "text": "We show the easy way to cook. Just stay at home with us",
      "image": "https://i.postimg.cc/3x3ZzL8C/splash-2.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    String? token = await _authService.getToken();

    // Jeda 3 detik agar animasi splash terlihat
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (token != null) {
      // Jika sudah ada token, langsung ke Home
      context.go('/app/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => Column(
                    children: <Widget>[
                      const Spacer(),
                      const Text(
                        "COOKMATE",
                        style: TextStyle(
                          fontSize: 36,
                          color: Color(0xFFFF7643),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(splashData[index]["text"]!,
                          textAlign: TextAlign.center),
                      const Spacer(flex: 2),
                      Image.network(
                        splashData[index]["image"]!,
                        height: 265,
                        width: 235,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 5),
                            height: 6,
                            width: currentPage == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? const Color(0xFFFF7643)
                                  : const Color(0xFFD8D8D8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/sign_in');
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFF7643),
                          foregroundColor: context.colors.cardBackground,
                          minimumSize: const Size(double.infinity, 48),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        child: const Text("Continue"),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
