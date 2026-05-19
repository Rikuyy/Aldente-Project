import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static String routeName = "/forgot_password";

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleForgot() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response =
        await _authService.forgotPassword(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ??
              "Kode OTP berhasil dikirim ke Gmail Anda!"),
          backgroundColor: Colors.green,
        ),
      );
      context.push('/otp', extra: _emailController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ??
              "Gagal mengirim OTP, cek koneksi internet"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white, title: const Text("Lupa Kata Sandi")),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                const Text(
                  "Lupa Kata Sandi",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Masukkan email Anda, kami akan mengirimkan\n4 digit kode OTP untuk memverifikasi akun Anda.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF757575)),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Masukkan email Anda";
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value))
                            return "Masukkan format email yang benar (@gmail.com)";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "Masukkan alamat email",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.string(mailIcon),
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF757575)),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleForgot,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFF7643),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text("Kirim Kode OTP"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const mailIcon =
    '''<svg width="18" height="13" viewBox="0 0 18 13" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M15.3576 3.39368C15.5215 3.62375 15.4697 3.94447 15.2404 4.10954L9.80876 8.03862C9.57272 8.21053 9.29421 8.29605 9.01656 8.29605C8.7406 8.29605 8.4638 8.21138 8.22775 8.04204L2.79373 4.10954C2.56439 3.94447 2.51261 3.62375 2.67648 3.39368C2.84035 3.16361 3.15933 3.11155 3.38867 3.27663L8.82269 7.20993C8.93922 7.29337 9.0939 7.29337 9.21043 7.20993L14.6421 3.28082C14.8714 3.11575 15.1937 3.16361 15.3576 3.39368Z" fill="#757575"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M1.77637 1.48022C1.77637 1.0716 2.10759 0.740381 2.51621 0.740381H15.4805C15.8891 0.740381 16.2203 1.0716 16.2203 1.48022V11.026C16.2203 11.4346 15.8891 11.7659 15.4805 11.7659H2.51621C2.10759 11.7659 1.77637 11.4346 1.77637 11.026V1.48022ZM3.25606 2.22061V10.2857H14.7407V2.22061H3.25606Z" fill="#757575"/>
</svg>''';
