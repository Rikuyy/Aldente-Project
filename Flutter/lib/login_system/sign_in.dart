import 'package:cook_cash/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_services.dart';

class SignInScreen extends StatelessWidget {
  static const String routeName = '/sign_in';

  const SignInScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.cardBackground,
      appBar: AppBar(
        backgroundColor: context.colors.cardBackground,
        title: const Text("Sign In"),
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
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign in with your email and password  \nor continue with social media",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const SignInForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocalCard(
                        icon: googleIcon,
                        press: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SocalCard(
                          icon: facebookIcon,
                          press: () {},
                        ),
                      ),
                      SocalCard(
                        icon: twitterIcon,
                        press: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final response = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response['access_token'] != null) {
      await _authService.saveToken(response['access_token']);
      if (!mounted) return;
      context.go('/app/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Login Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
                hintText: "Enter your email",
                labelText: "Email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.string(mailIcon),
                ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                    borderSide: const BorderSide(color: Color(0xFFFF7643)))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "Enter your password",
                  labelText: "Password",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.string(lockIcon),
                  ),
                  border: authOutlineInputBorder,
                  enabledBorder: authOutlineInputBorder,
                  focusedBorder: authOutlineInputBorder.copyWith(
                      borderSide: const BorderSide(color: Color(0xFFFF7643)))),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFF7643),
              foregroundColor: context.colors.cardBackground,
              minimumSize: const Size(double.infinity, 48),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text("Continue"),
          )
        ],
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class SocalCard extends StatelessWidget {
  const SocalCard({super.key, required this.icon, required this.press});
  final String icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
            color: Color(0xFFF5F6F9), shape: BoxShape.circle),
        child: SvgPicture.string(icon),
      ),
    );
  }
}

class NoAccountText extends StatelessWidget {
  const NoAccountText({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? ",
                style: TextStyle(color: Color(0xFF757575))),
            GestureDetector(
              onTap: () => context.push('/sign_up'),
              child: const Text("Sign Up",
                  style: TextStyle(color: Color(0xFFFF7643))),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.push('/forgot_password'),
          child: const Text("Forgot Password",
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xFF757575))),
        ),
      ],
    );
  }
}

const mailIcon =
    '''<svg width="18" height="13" viewBox="0 0 18 13" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M15.3576 3.39368C15.5215 3.62375 15.4697 3.94447 15.2404 4.10954L9.80876 8.03862C9.57272 8.21053 9.29421 8.29605 9.01656 8.29605C8.7406 8.29605 8.4638 8.21138 8.22775 8.04204L2.79373 4.10954C2.56447 3.94447 2.51261 3.62375 2.67652 3.39368C2.84042 3.16361 3.15984 3.11157 3.3891 3.27664L8.81434 7.20336C8.93237 7.28788 9.10086 7.28788 9.21889 7.20336L14.645 3.27664C14.8743 3.11157 15.1937 3.16361 15.3576 3.39368ZM1.18421 1.11842C0.686526 1.11842 0.282895 1.52205 0.282895 2.01974V10.1382C0.282895 11.2327 1.17 12.1197 2.26447 12.1197H15.7697C16.8642 12.1197 17.7513 11.2327 17.7513 10.1382V2.01974C17.7513 1.52205 17.3477 1.11842 16.85 1.11842H1.18421ZM16.85 0H1.18421C0.0716842 0 -0.815789 0.887474 -0.815789 2V10.1382C-0.815789 11.8363 0.566316 13.2184 2.26447 13.2184H15.7697C17.4679 13.2184 18.85 11.8363 18.85 10.1382V2C18.85 0.887474 17.9625 0 16.85 0Z" fill="#757575"/></svg>''';

const lockIcon =
    '''<svg width="14" height="18" viewBox="0 0 14 18" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M3.56579 5.92105V4.28289C3.56579 2.41461 5.07697 0.903421 6.94526 0.903421C8.81355 0.903421 10.3247 2.41461 10.3247 4.28289V5.92105H3.56579ZM1.31579 5.92105V4.28289C1.31579 1.17382 3.83618 -1.34658 6.94526 -1.34658C10.0543 -1.34658 12.5747 1.17382 12.5747 4.28289V5.92105H12.8553C13.9712 5.92105 14.875 6.82487 14.875 7.94079V15.8289C14.875 16.9449 13.9712 17.8487 12.8553 17.8487H1.03487C-0.0810526 17.8487 -0.984868 16.9449 -0.984868 15.8289V7.94079C-0.984868 6.82487 -0.0810526 5.92105 1.03487 5.92105H1.31579ZM1.125 7.04605H12.7651C13.2731 7.04605 13.6842 7.45711 13.6842 7.96513V15.8033C13.6842 16.3113 13.2731 16.7224 12.7651 16.7224H1.125C0.616974 16.7224 0.205921 16.3113 0.205921 15.8033V7.96513C0.205921 7.45711 0.616974 7.04605 1.125 7.04605Z" fill="#757575"/></svg>''';

const googleIcon =
    '''<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M14.6738 7.65345C14.6738 7.15172 14.6301 6.64998 14.5427 6.16113H7.49841V8.9959H11.5348C11.3653 9.91494 10.841 10.7275 10.0654 11.2518V13.1031H12.4357C13.823 11.821 14.6738 9.91494 14.6738 7.65345Z" fill="#4285F4"/><path d="M7.49811 15.0001C9.5188 15.0001 11.2227 14.3283 12.4411 13.1741L10.0708 11.3228C9.41005 11.7651 8.54162 12.0218 7.50357 12.0218C5.55396 12.0218 3.90471 10.6946 3.31489 8.91412H0.857422V10.8146C2.09708 13.294 4.65301 15.0001 7.49811 15.0001Z" fill="#34A853"/><path d="M3.30932 8.91408C3.00349 7.99504 3.00349 7.00108 3.30932 6.08204V4.18152H0.857313C-0.180327 6.25141 -0.180327 8.73919 0.857313 10.8091L3.30932 8.91408Z" fill="#FBBC04"/><path d="M7.49811 2.97825C8.56847 2.96187 9.59518 3.36601 10.3543 4.10952L12.4848 1.97905C11.1303 0.684739 9.33857 -0.0252118 7.49811 5.43896e-05C4.65301 5.43896e-05 2.09708 1.7061 0.857422 4.18552L3.30943 6.08604C3.90471 4.30556 5.55396 2.97825 7.49811 2.97825Z" fill="#EA4335"/></svg>''';

const facebookIcon =
    '''<svg width="8" height="15" viewBox="0 0 8 15" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M5.02224 14.8963V8.10133H7.30305L7.64452 5.45323H5.02224V3.7625C5.02224 2.99583 5.23517 2.4733 6.33467 2.4733L7.73695 2.47265V0.104232C7.49432 0.0720777 6.66197 0 5.6936 0C3.67183 0 2.28768 1.23402 2.28768 3.50037V5.4533H0.000976562V8.1014H2.28761V14.8963L5.02224 14.8963Z" fill="#3C5A9A"/></svg>''';

const twitterIcon =
    '''<svg width="16" height="14" viewBox="0 0 16 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15.9821 1.53761C15.3946 1.7981 14.7629 1.97334 14.1005 2.05267C14.7766 1.64765 15.2952 1.00645 15.5393 0.24233C14.9062 0.617942 14.2057 0.890334 13.4599 1.03719C12.8624 0.40058 12.011 0 11.0691 0C9.25992 0 7.79159 1.46824 7.79159 3.27733C7.79159 3.53428 7.82069 3.78426 7.87679 4.0238C5.15424 3.88714 2.73377 2.57945 1.11504 0.596245C0.832966 1.08055 0.671309 1.64375 0.671309 2.24434C0.671309 3.38072 1.25015 4.38466 2.12812 4.97136C1.59051 4.95435 1.08985 4.80662 0.651792 4.56306V4.60424C0.651792 6.19106 1.78168 7.51475 3.28148 7.81595C3.00639 7.8906 2.71676 7.93069 2.41775 7.93069C2.20666 7.93069 2.00127 7.91024 1.80131 7.87208C2.21817 9.17296 3.4267 10.121 4.8596 10.1472C3.73892 11.0256 2.32674 11.5487 0.791771 11.5487C0.527315 11.5487 0.266504 11.5332 0.0101562 11.5029C1.45914 12.4316 3.17983 12.9733 5.02847 12.9733C11.0487 12.9733 14.3377 7.98606 14.3377 3.66669C14.3377 3.52504 14.3345 3.38421 14.3282 3.24419C14.9678 2.78248 15.5235 2.20015 15.9821 1.53761Z" fill="#1DA1F2"/></svg>''';
