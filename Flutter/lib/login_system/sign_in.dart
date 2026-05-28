import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_services.dart';

class SignInScreen extends StatefulWidget {
  static const String routeName = '/sign_in';

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(); // Ganti dari email
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscureText = true;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await _authService.login(
      _usernameController.text.trim(), // Kirim username
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login Berhasil!"), backgroundColor: Colors.green),
      );

      final bool needsOnboarding = response['needs_onboarding'] ?? true;

      if (needsOnboarding) {
        context.go('/onboarding');
      } else {
        context.go('/app/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(response['message'] ?? "Username atau password salah"),
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
                    "Masuk dengan username dan password Anda \natau lanjutkan dengan media sosial",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "Username",
                            hintText: "Masukkan username Anda",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 42, vertical: 20),
                            enabledBorder: authOutlineInputBorder,
                            focusedBorder: authOutlineInputBorder,
                            border: authOutlineInputBorder,
                            suffixIcon: Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 20, 20),
                              child:
                                  Icon(Icons.person, color: Color(0xFF757575)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            if (value.length < 3) {
                              return 'Username minimal 3 karakter';
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
