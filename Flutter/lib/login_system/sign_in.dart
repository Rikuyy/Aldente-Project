import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_services.dart';
import 'sign_up.dart';

class SignInScreen extends StatefulWidget {
  static const String routeName = '/sign_in';

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscureText = true;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login Berhasil!"), backgroundColor: Colors.green),
      );

      // REVISI LOGIKA NAVIGASI: Cek status apakah user baru pertama kali login
      // Menyesuaikan dengan data yang dikirim oleh backend Laravel kamu
      final bool isNewUser = response['user']?['is_new_user'] ?? true;

      if (isNewUser) {
        // Jika pertama kali login, arahkan ke halaman pengisian data kuesioner
        context.go('/onboarding');
      } else {
        // Jika sudah pernah mengisi data/bukan user baru, langsung ke Dashboard Utama
        context.go('/app/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ?? "Email atau password salah"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Masuk",
          style: TextStyle(color: Color(0xFF757575), fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  const Text(
                    "Selamat Datang Kembali",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Masuk dengan email dan password Anda \natau lanjutkan dengan media sosial",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Masukkan email Anda",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 42, vertical: 20),
                            enabledBorder: authOutlineInputBorder,
                            focusedBorder: authOutlineInputBorder,
                            border: authOutlineInputBorder,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                              child: SvgPicture.string(mailIcon),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Masukkan email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Masukkan password Anda",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 42, vertical: 20),
                            enabledBorder: authOutlineInputBorder,
                            focusedBorder: authOutlineInputBorder,
                            border: authOutlineInputBorder,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF757575),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.push('/forgot_password'),
                              child: const Text(
                                "Lupa Password?",
                                style: TextStyle(
                                    decoration: TextDecoration.underline),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFFF7643),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text("Masuk"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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

class NoAccountText extends StatelessWidget {
  const NoAccountText({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun? ",
            style: TextStyle(color: Color(0xFF757575))),
        GestureDetector(
          onTap: () => context.push('/sign_up'),
          child: const Text("Daftar Sekarang",
              style: TextStyle(
                  color: Color(0xFFFF7643), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

const mailIcon =
    '''<svg width=\"18\" height=\"13\" viewBox=\"0 0 18 13\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M15.3576 3.39368C15.524 3.51336 15.625 3.70519 15.625 3.9103V10.7419C15.625 11.4552 15.011 12.0335 14.2541 12.0335H3.74591C2.98895 12.0335 2.375 11.4552 2.375 10.7419V3.9103C2.375 3.70519 2.47596 3.51336 2.64237 3.39368L8.41169 7.5401C8.76295 7.79255 9.23705 7.79255 9.58831 7.5401L15.3576 3.39368ZM3.74591 0.966431H14.2541C14.7709 0.966431 15.222 1.24075 15.4668 1.6508L9.00003 6.29828L2.5332 1.6508C2.77803 1.24075 3.22912 0.966431 3.74591 0.966431Z\" fill=\"#757575\"/></svg>''';
