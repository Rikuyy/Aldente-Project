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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Forgot Password"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                const Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Please enter your email and we will send \nyou a link to return to your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF757575)),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "Enter your email",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.string(mailIcon),
                          ),
                          border: authOutlineInputBorder,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleForgot,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFF7643),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text("Continue"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                const NoAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
