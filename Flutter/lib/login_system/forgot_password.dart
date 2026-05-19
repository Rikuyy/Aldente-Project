import 'package:cook_cash/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_services.dart';
import 'sign_up.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static String routeName = "/forgot_password";

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleForgot() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil fungsi forgotPassword di AuthService
    final response =
        await _authService.forgotPassword(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? "Check your connection")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.cardBackground,
      appBar: AppBar(
        backgroundColor: context.colors.cardBackground,
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please enter your email and we will send \nyou a link to return to your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  const ForgotPasswordForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                  const NoAccountText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            onSaved: (email) {},
            onChanged: (email) {},
            decoration: InputDecoration(
                hintText: "Enter your email",
                labelText: "Email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffix: SvgPicture.string(
                  mailIcon,
                ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                    borderSide: const BorderSide(color: Color(0xFFFF7643)))),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, OtpScreen.routeName);
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
          )
        ],
      ),
    );
  }
}


class NoAccountText extends StatelessWidget {
  const NoAccountText({
    super.key,
  });
// --- Komponen Pendukung ---
const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class NoAccountText extends StatelessWidget {
  const NoAccountText({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don’t have an account? ",
            style: TextStyle(color: Color(0xFF757575))),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, SignUpScreen.routeName),
          child:
              const Text("Sign Up", style: TextStyle(color: Color(0xFFFF7643))),
        ),
      ],
    );
  }
}

const mailIcon =
    '''<svg width="18" height="13" viewBox="0 0 18 13" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M15.3576 3.39368C15.5215 3.62375 15.4697 3.94447 15.2404 4.10954L9.80876 8.03862C9.57272 8.21053 9.29421 8.29605 9.01656 8.29605C8.7406 8.29605 8.4638 8.21138 8.22775 8.04204L2.79373 4.10954C2.56447 3.94447 2.51261 3.62375 2.67652 3.39368C2.84042 3.16361 3.15984 3.11157 3.3891 3.27664L8.81434 7.20336C8.93237 7.28788 9.10086 7.28788 9.21889 7.20336L14.645 3.27664C14.8743 3.11157 15.1937 3.16361 15.3576 3.39368ZM1.18421 1.11842C0.686526 1.11842 0.282895 1.52205 0.282895 2.01974V10.1382C0.282895 11.2327 1.17 12.1197 2.26447 12.1197H15.7697C16.8642 12.1197 17.7513 11.2327 17.7513 10.1382V2.01974C17.7513 1.52205 17.3477 1.11842 16.85 1.11842H1.18421ZM16.85 0H1.18421C0.0716842 0 -0.815789 0.887474 -0.815789 2V10.1382C-0.815789 11.8363 0.566316 13.2184 2.26447 13.2184H15.7697C17.4679 13.2184 18.85 11.8363 18.85 10.1382V2C18.85 0.887474 17.9625 0 16.85 0Z" fill="#757575"/></svg>''';
